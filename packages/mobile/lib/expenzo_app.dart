import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saropa_drift_advisor/saropa_drift_advisor.dart';

import 'core/database/app_database.dart';
import 'core/di/injection_container.dart' as di;
import 'core/lifecycle/bootstrap_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/categories/presentation/bloc/category_event.dart';
import 'features/records/presentation/bloc/record_bloc.dart';
import 'features/records/presentation/bloc/record_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/sms_parser/application/realtime_sms_processor.dart';
import 'features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'shared/presentation/pages/feedback_page.dart';
import 'shared/presentation/widgets/app_error_fallback.dart';

class ExpenzoApp extends StatefulWidget {
  const ExpenzoApp({super.key});

  @override
  State<ExpenzoApp> createState() => _ExpenzoAppState();
}

class _ExpenzoAppState extends State<ExpenzoApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(navigatorKey: _navigatorKey);
    _startInitialization();
  }

  AppRouter? _appRouter;
  bool _initialized = false;
  bool _error = false;
  String _errorRefId = '';

  Future<void> _startInitialization() async {
    try {
      await _initFirebase();
      await di.initCriticalDependencies();
      if (!mounted) return;

      if (kDebugMode) {
        await _startDriftDebugServer();
      }

      await di.getIt<BootstrapService>().seedInitialData();
      _initSettingsWhenReady();

      if (mounted) {
        setState(() {
          _initialized = true;
          _error = false;
        });
      }

      unawaited(_tryStartRealtimeSmsProcessing());

      // Feature deps no longer need the 500ms delay — the
      // `featureDependenciesReady` getter is self-healing.
      await di.initFeatureDependencies();
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

  Future<void> _startDriftDebugServer() async {
    final db = di.getIt<AppDatabase>();
    try {
      await db.startDriftViewer(
        enabled: kDebugMode,
        getDatabaseBytes: _readDbBytes,
        writeQuery: (sql) => db.customStatement(sql),
      );
      debugPrint('Drift debug server ready on http://127.0.0.1:8642/');
    } catch (e, s) {
      debugPrint('Drift debug server failed to start: $e\n$s');
    }
  }

  Future<List<int>> _readDbBytes() async {
    final db = di.getIt<AppDatabase>();

    return File(await db.dbPath).readAsBytes();
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
    Future.delayed(const Duration(milliseconds: 150), _loadCategories);
  }

  void _dispatchDelayedRecordLoad() {
    Future.delayed(const Duration(milliseconds: 300), _loadRecords);
  }

  void _loadCategories() {
    if (!mounted) return;
    final ctx = _navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ctx.read<CategoryBloc>().add(const LoadCategories());
    }
  }

  void _loadRecords() {
    if (!mounted) return;
    final ctx = _navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ctx.read<RecordBloc>().add(const LoadRecords());
    }
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
  const _AppContent({
    required this.child,
    required this.initialized,
    required this.error,
    required this.errorRefId,
    required this.onInitLoads,
  });

  final Widget child;
  final bool initialized;
  final bool error;
  final String errorRefId;
  final VoidCallback onInitLoads;

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

  // AppErrorFallback manages retry internally; this callback exists only
  // to satisfy the VoidCallback contract.
  void _handleRetry() {
    return;
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

  AnimationController? _controller;
  Animation<double>? _animation;

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
