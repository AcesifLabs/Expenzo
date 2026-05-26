import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
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
import 'shared/presentation/widgets/app_shell.dart';
import 'shared/presentation/widgets/app_error_view.dart';
import 'core/database/database_seeder.dart';
import 'core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isProd = bool.fromEnvironment('dart.vm.product');
  try {
    await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');
  } catch (e) {
    // App works without .env — falls back to localhost
    debugPrint('Failed to load .env: $e');
  }

  // Framework error UI swap
  ErrorWidget.builder = (details) => AppErrorView(details: details);

  // Global error logging
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // Log to service
    }
  };

  // Async error catch
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('Async Error: $error');
    }
    return true;
  };

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
    _tryInitSettings();
  }

  void _tryInitSettings() {
    try {
      final bloc = di.getIt<SettingsBloc>()..add(const LoadSettings());
      _settingsSubscription = bloc.stream.listen((state) {
        if (state is SettingsLoaded) {
          _themeModeNotifier.value =
              _themeModeFromString(state.settings.theme);
        } else if (state is SettingsUpdateSuccess) {
          _themeModeNotifier.value =
              _themeModeFromString(state.settings.theme);
        }
      });
    } catch (_) {
      // Not registered yet (init still running) — retry after frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryInitSettings());
    }
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
          home: const AppLoader(),
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
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with WidgetsBindingObserver {
  bool _initialized = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInitialization();
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

  Future<void> _startInitialization() async {
    // Firebase init — non-fatal. App works offline without Firebase.
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

    // DI + DB — fatal. App cannot function without local database.
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

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        di.initFeatureDependencies();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _errorMessage = e.toString();
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

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startInitialization,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildSplash(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(child: _SplashIcon()),
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
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Stagger to avoid GC spike from concurrent DB queries
      context.read<AuthBloc>().add(const AuthCheckRequested());
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          context.read<CategoryBloc>().add(const LoadCategories());
        }
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          context.read<RecordBloc>().add(const LoadRecords());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signed in as ${state.user.email ?? state.user.displayName ?? 'User'}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is AuthError) {
          // Only show error snackbar if user explicitly tried to sign in
          if (state.isUserInitiated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sign-in failed: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } else if (state is AuthLoading) {
          // Optionally show a loading indicator — currently AppShell renders normally
        }
      },
      builder: (context, state) {
        if (state is AuthSyncConflictPending) {
          return const SyncConflictPage();
        }
        // Unauthenticated, AuthInitial, Authenticated, AuthLoading,
        // AuthError — all render AppShell (app accessible without sign-in)
        return const AppShell();
      },
    );
  }
}
