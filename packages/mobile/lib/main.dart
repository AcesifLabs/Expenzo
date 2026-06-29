// ignore_for_file: prefer-match-file-name

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/lifecycle/bootstrap_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/sync_conflict_page.dart';
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
import 'shared/presentation/widgets/app_shell.dart';
import 'shared/presentation/widgets/app_critical_error.dart';
import 'shared/presentation/widgets/app_error_fallback.dart';
import 'core/database/database_seeder.dart';
import 'core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isProd = bool.fromEnvironment('dart.vm.product');
  try {
    await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');
  } catch (e) {
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
  final _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  StreamSubscription? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _initSettingsWhenReady();
  }

  Future<void> _initSettingsWhenReady() async {
    await di.criticalDependenciesReady;
    if (!mounted) return;

    final bloc = di.getIt<SettingsBloc>()..add(const LoadSettings());
    _settingsSubscription = bloc.stream.listen((state) {
      if (state is SettingsLoaded) {
        _themeModeNotifier.value = _themeModeFromString(state.settings.theme);
      } else if (state is SettingsUpdateSuccess) {
        _themeModeNotifier.value = _themeModeFromString(state.settings.theme);
      }
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Expenzo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: AppLoader(feedbackBuilder: (_) => const FeedbackPage()),
        );
      },
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

class AppLoader extends StatefulWidget {
  const AppLoader({super.key, this.feedbackBuilder});

  final WidgetBuilder? feedbackBuilder;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with WidgetsBindingObserver {
  bool _initialized = false;
  bool _error = false;
  String _errorRefId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInitialization();
  }

  Widget _buildSplash(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(child: _SplashIcon()),
    );
  }

  void _handleRetry() {
    setState(() {
      _error = false;
      _initialized = false;
    });
    _startInitialization();
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

  Future<void> _startInitialization() async {
    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Firebase init timed out — proceeding offline');
          throw TimeoutException('Firebase init timed out');
        },
      );
    } catch (e) {
      debugPrint('Firebase init failed (non-fatal): $e');
    }

    try {
      await di.initCriticalDependencies();

      final db = di.getIt<AppDatabase>();
      try {
        await DatabaseSeeder.seedInitialCategories(db);
      } catch (e) {
        debugPrint('DatabaseSeeder failed (non-fatal): $e');
      }

      if (mounted) {
        setState(() => _initialized = true);
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
      debugPrint('AppLoader: init failed: $e\n$stack');
      if (mounted) {
        setState(() {
          _error = true;
          _errorRefId = AppErrorFallback.generateReferenceId();
        });
      }
    }
  }

  Future<void> _tryStartRealtimeSmsProcessing() async {
    try {
      final status = await Permission.sms.status;
      if (!status.isGranted) return;
      await di.getIt<RealtimeSmsProcessor>().start();
    } catch (e) {
      debugPrint('Realtime SMS start skipped: $e');
    }
  }

  Future<void> _tryDrainRealtimeSms() async {
    try {
      final status = await Permission.sms.status;
      if (!status.isGranted) return;
      await di.getIt<RealtimeSmsProcessor>().drainPendingMessages();
    } catch (e) {
      debugPrint('Realtime SMS drain skipped: $e');
    }
  }

  void _initFeatureDependencies() {
    di.initFeatureDependencies();
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
    if (_error) {
      return AppErrorFallback(
        fallbackContext: AppFallbackContext.init,
        referenceId: _errorRefId,
        feedbackBuilder: widget.feedbackBuilder,
        onRetry: _handleRetry,
        onHardReset: _handleHardReset,
        onRestart: _handleRestart,
      );
    }

    if (!_initialized) {
      return _buildSplash(context);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.getIt<AuthBloc>()),
        BlocProvider<CategoryBloc>(create: (_) => di.getIt<CategoryBloc>()),
        BlocProvider<RecordBloc>(create: (_) => di.getIt<RecordBloc>()),
        BlocProvider<SmsScannerBloc>(create: (_) => di.getIt<SmsScannerBloc>()),
      ],
      child: const _InitialDataLoader(),
    );
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

class _InitialDataLoader extends StatefulWidget {
  const _InitialDataLoader();

  @override
  State<_InitialDataLoader> createState() => _InitialDataLoaderState();
}

class _InitialDataLoaderState extends State<_InitialDataLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onPostFrameCallback);
  }

  void _onPostFrameCallback(_) {
    if (!mounted) return;

    context.read<AuthBloc>().add(const AuthCheckRequested());
    Future.delayed(const Duration(milliseconds: 150), _loadCategories);
    Future.delayed(const Duration(milliseconds: 300), _loadRecords);
  }

  void _loadCategories() {
    if (mounted) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }
  }

  void _loadRecords() {
    if (mounted) {
      context.read<RecordBloc>().add(const LoadRecords());
    }
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthError) {
      if (state.isUserInitiated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${state.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _onAuthStateChanged,
      builder: (context, state) {
        if (state is AuthSyncConflictPending) {
          return const SyncConflictPage();
        }

        return const AppShell();
      },
    );
  }
}
