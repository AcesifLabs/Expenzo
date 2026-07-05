// ignore_for_file: prefer-match-file-name

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/lifecycle/bootstrap_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/categories/presentation/bloc/category_event.dart';
import 'features/records/presentation/bloc/record_bloc.dart';
import 'features/records/presentation/bloc/record_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'features/sms_parser/application/realtime_sms_processor.dart';
import 'shared/presentation/pages/feedback_page.dart';
import 'shared/presentation/widgets/app_critical_error.dart';
import 'shared/presentation/widgets/app_error_fallback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isProd = bool.fromEnvironment('dart.vm.product');
  try {
    await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');
  } catch (e, s) {
    debugPrint('Error: $e\n$s');
    debugPrint('Failed to load .env: $e');
  }

  ErrorWidget.builder = (details) => AppCriticalError(details: details);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // TODO: report to crash reporting service
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Async Error: $error\n$stack');
    }

    return true;
  };

  di.getIt.registerSingleton<BootstrapService>(
    BootstrapService(remountRoot: () async => runApp(const ExpenzoApp())),
  );

  runApp(const ExpenzoApp());
}

class ExpenzoApp extends StatefulWidget {
  const ExpenzoApp({super.key});

  @override
  State<ExpenzoApp> createState() => _ExpenzoAppState();
}

class _ExpenzoAppState extends State<ExpenzoApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  AppRouter? _appRouter;

  bool _initialized = false;
  bool _error = false;
  String _errorRefId = '';

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(navigatorKey: _navigatorKey);
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      await _initFirebase();
      await di.initCriticalDependencies();
      if (!mounted) return;

      await di.getIt<BootstrapService>().seedInitialData();
      _initSettingsWhenReady();

      if (mounted) {
        setState(() {
          _initialized = true;
          _error = false;
        });
      }

      unawaited(_tryStartRealtimeSmsProcessing());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          Future.delayed(
            const Duration(milliseconds: 500),
            _initFeatureDependencies,
          ),
        );
      });
    } catch (e, stack) {
      debugPrint('App init failed: $e\n$stack');
      if (mounted) {
        setState(() {
          _error = true;
          _errorRefId = AppErrorFallback.generateReferenceId();
        });
      }
    }
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Firebase init timed out — proceeding offline');
          throw TimeoutException('Firebase init timed out');
        },
      );
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('Firebase init failed (non-fatal): $e');
    }
  }

  Future<void> _initSettingsWhenReady() async {
    await di.criticalDependenciesReady;
    if (!mounted) return;
    final bloc = di.getIt<SettingsBloc>()..add(const LoadSettings());
    bloc.stream.listen((state) {
      if (state is SettingsLoaded) {
        _themeModeNotifier.value = _themeModeFromString(state.settings.theme);
      } else if (state is SettingsUpdateSuccess) {
        _themeModeNotifier.value = _themeModeFromString(state.settings.theme);
      }
    });
  }

  Future<void> _tryStartRealtimeSmsProcessing() async {
    try {
      final status = await Permission.sms.status;
      if (!status.isGranted) return;
      await di.getIt<RealtimeSmsProcessor>().start();
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('Realtime SMS start skipped: $e');
    }
  }

  void _initFeatureDependencies() {
    di.initFeatureDependencies();
  }

  void _dispatchInitialLoads() {
    try {
      final navContext = _navigatorKey.currentContext;
      if (navContext == null) return;
      navContext.read<AuthBloc>().add(const AuthCheckRequested());
      _dispatchDelayedCategoryLoad();
      _dispatchDelayedRecordLoad();
    } catch (e, s) {
      debugPrint('Initial loads dispatch failed: $e\n$s');
    }
  }

  void _dispatchDelayedCategoryLoad() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final ctx = _navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        ctx.read<CategoryBloc>().add(const LoadCategories());
      }
    });
  }

  void _dispatchDelayedRecordLoad() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final ctx = _navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        ctx.read<RecordBloc>().add(const LoadRecords());
      }
    });
  }

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'Expenzo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: _appRouter?.config,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(create: (_) => di.getIt<AuthBloc>()),
                BlocProvider<CategoryBloc>(
                  create: (_) => di.getIt<CategoryBloc>(),
                ),
                BlocProvider<RecordBloc>(create: (_) => di.getIt<RecordBloc>()),
                BlocProvider<SmsScannerBloc>(
                  create: (_) => di.getIt<SmsScannerBloc>(),
                ),
              ],
              child: _AppContent(
                initialized: _initialized,
                error: _error,
                errorRefId: _errorRefId,
                onInitLoads: _dispatchInitialLoads,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

class _AppContent extends StatefulWidget {
  final Widget child;
  final bool initialized;
  final bool error;
  final String errorRefId;
  final VoidCallback onInitLoads;

  const _AppContent({
    required this.child,
    required this.initialized,
    required this.error,
    required this.errorRefId,
    required this.onInitLoads,
  });

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInitLoads();
      });
    }
  }

  Future<void> _tryDrainRealtimeSms() async {
    try {
      final status = await Permission.sms.status;
      if (!status.isGranted) return;
      await di.getIt<RealtimeSmsProcessor>().drainPendingMessages();
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('Realtime SMS drain skipped: $e');
    }
  }

  // ignore: no-empty-block
  void _handleRetry() {
    /* handled by error fallback widget */
  }

  void _handleHardReset() {
    unawaited(
      di.getIt<BootstrapService>().hardReset().then((_) {
        if (!mounted) return;
        di.getIt<BootstrapService>().remountRoot();
      }),
    );
  }

  void _handleRestart() {
    di.getIt<BootstrapService>().restart();
  }

  Widget _buildSplash(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(child: _SplashIcon()),
    );
  }

  @override
  void didUpdateWidget(_AppContent old) {
    super.didUpdateWidget(old);
    if (!old.initialized && widget.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInitLoads();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_tryDrainRealtimeSms());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.error) {
      return AppErrorFallback(
        fallbackContext: AppFallbackContext.init,
        referenceId: widget.errorRefId,
        feedbackBuilder: (_) => const FeedbackPage(),
        onRetry: _handleRetry,
        onHardReset: _handleHardReset,
        onRestart: _handleRestart,
      );
    }

    if (!widget.initialized) {
      return _buildSplash(context);
    }

    return widget.child;
  }
}

class _SplashIcon extends StatefulWidget {
  const _SplashIcon();

  @override
  State<_SplashIcon> createState() => _SplashIconState();
}

class _SplashIconState extends State<_SplashIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _controller = controller;
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final animation = _animation;
    if (controller == null || animation == null) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: animation,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: 80, height: 80),
          const SizedBox(height: 16),
          Text(
            'Expenzo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

ThemeMode _themeModeFromString(String theme) {
  return switch (theme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
