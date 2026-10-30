import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saropa_drift_advisor/saropa_drift_advisor.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/logger/crash_reporter.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/theme/first_day_material_localizations.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/resolve_onboarding_status.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_text_scale.dart';
import 'package:expense_tracker/shared/presentation/widgets/currency_scope.dart';
import 'package:expense_tracker/shared/presentation/widgets/locale_scope.dart';
import 'package:expense_tracker/core/router/cold_start_location.dart';
import 'package:expense_tracker/core/router/refresh_on_auth_change.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_switch_watcher.dart';
import 'package:expense_tracker/shared/services/feedback_mailer.dart';
import 'package:expense_tracker/shared/services/notification_permission.dart';

import 'core/background/background_task_scheduler.dart';
import 'core/database/app_database.dart';
import 'core/database/database_file.dart';
import 'i18n/strings.g.dart';
import 'core/di/injection_container.dart' as di;
import 'core/lifecycle/bootstrap_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/categories/presentation/bloc/category_event.dart';
import 'features/records/presentation/bloc/record_bloc.dart';
import 'features/recurring/application/recurring_auto_poster.dart';
import 'features/recurring/domain/usecases/send_recurring_reminders.dart';
import 'features/records/presentation/bloc/record_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/presentation/helpers/first_settings.dart';
import 'features/sms_parser/application/realtime_sms_processor.dart';
import 'features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'shared/presentation/widgets/app_error_fallback.dart';

Future<void> _runRecurringAppOpenWork() async {
  try {
    if (di.getIt.isRegistered<RecurringAutoPoster>()) {
      await di.getIt<RecurringAutoPoster>().runWhenReady();
    }
    if (di.getIt.isRegistered<SendRecurringReminders>()) {
      await di.getIt<SendRecurringReminders>()(now: DateTime.now());
    }
  } catch (e, s) {
    appLogger.error('Recurring app-open work failed', e, s);
  }
}

class ExpenzoApp extends StatefulWidget {
  const ExpenzoApp({super.key});

  @override
  State<ExpenzoApp> createState() => _ExpenzoAppState();
}

class _ExpenzoAppState extends State<ExpenzoApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  final _fontScaleNotifier = ValueNotifier<double>(
    AppFontSize.defaultSize.scale,
  );

  final _syncSwitch = SyncSwitchWatcher(
    ({required enabled}) =>
        di.getIt<SyncEngine>().applyEnabled(enabled: enabled),
  );

  StreamSubscription<AppLocale>? _localeSubscription;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(navigatorKey: _navigatorKey);
    _localeSubscription = LocaleSettings.getLocaleStream().listen(
      _onLocaleChanged,
    );
    _startInitialization();
  }

  AppRouter? _appRouter;
  bool _initialized = false;
  bool _error = false;
  String _errorRefId = '';

  bool _databaseUnreadable = false;

  bool _backgroundArmed = false;

  UserSettings? _lastSettings;

  Future<void> _startInitialization() async {
    try {
      final firebase = _initFirebase();
      await di.initCriticalDependencies();

      await di.getIt<AppDatabase>().customSelect('SELECT 1').get();
      await firebase;
      if (!mounted) return;

      await di.getIt<ResolveOnboardingStatus>()();

      if (kDebugMode) {
        await _startDriftDebugServer();
      }

      final firstLoaded = _initSettingsWhenReady();
      await di.getIt<BootstrapService>().seedInitialData();
      _applyHomeTab(await firstLoaded);

      if (mounted) {
        setState(() {
          _initialized = true;
          _error = false;
        });
      }

      unawaited(_tryStartRealtimeSmsProcessing());

      await di.initFeatureDependencies();
      unawaited(_runRecurringAppOpenWork());
    } catch (e, stack) {
      debugPrint('App init failed: $e\n$stack');
      final reference = AppErrorFallback.generateReferenceId();
      unawaited(crashReporter.capture(e, stack, reference: reference));
      if (mounted) {
        setState(() {
          _error = true;
          _errorRefId = reference;
          _databaseUnreadable = isDatabaseFileError(e);
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
      appLogger.error('Drift debug server failed to start', e, s);
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
      appLogger.error('Firebase init failed (non-fatal)', e, s);
    }
  }

  Future<UserSettings?> _initSettingsWhenReady() async {
    await di.criticalDependenciesReady;
    if (!mounted) return null;
    final bloc = di.getIt<SettingsBloc>()..add(const LoadSettings());
    bloc.stream.listen((state) {
      if (state is SettingsLoaded) {
        _applySettings(state.settings);
      } else if (state is SettingsUpdateSuccess) {
        _applySettings(state.settings);
      }
    });

    return firstSettings(bloc.stream);
  }

  void _applyHomeTab(UserSettings? settings) {
    final router = _appRouter?.config;
    if (settings == null || router == null) return;
    final location = coldStartLocation(
      current: router.routeInformationProvider.value.uri,
      homeTab: settings.homeTab,
    );
    if (location != null) router.go(location);
  }

  void _applySettings(UserSettings settings) {
    final onboardingChanged =
        _lastSettings?.onboardingCompleted != settings.onboardingCompleted;
    _lastSettings = settings;

    if (onboardingChanged) _appRouter?.config.refresh();
    _themeModeNotifier.value = _themeModeFromString(settings.theme);
    _fontScaleNotifier.value = settings.fontSize.scale;
    CurrencyFormatter.current.value = CurrencyConfig.byCode(
      settings.currencyCode,
    );
    CurrencyFormatter.displayFormat.value = NumberDisplayFormat(
      decimalPlaces: settings.decimalPlaces,
      grouping: settings.digitGrouping,
    );
    _applyLanguage(settings.languageCode);
    _applyWeekStart();
    unawaited(_applyBackgroundWork(settings));
    _syncSwitch.update(enabled: settings.syncEnabled);
    unawaited(crashReporter.setEnabled(enabled: settings.crashReportsEnabled));
  }

  bool _applyWeekStart() {
    final settings = _lastSettings;
    if (settings == null) return false;

    return WeekStart.apply(
      settings.effectiveFirstDayOfWeek(
        LocaleSettings.currentLocale.languageCode,
      ),
    );
  }

  void _onLocaleChanged(AppLocale locale) {
    Intl.defaultLocale = locale.languageTag;
    final settings = _lastSettings;

    if (_applyWeekStart() && settings != null) {
      unawaited(_applyBackgroundWork(settings));
    }
  }

  Future<void> _applyBackgroundWork(UserSettings settings) async {
    try {
      await di.featureDependenciesReady;
      final force = !_backgroundArmed;
      _backgroundArmed = true;
      await di.getIt<BackgroundTaskScheduler>().apply(settings, force: force);
    } catch (e, s) {
      appLogger.error('Background work scheduling failed', e, s);
    }
  }

  void _applyLanguage(String languageCode) {
    final locale = languageCode == 'system'
        ? LocaleSettings.useDeviceLocaleSync()
        : LocaleSettings.setLocaleRawSync(languageCode);
    Intl.defaultLocale = locale.languageTag;
  }

  Future<void> _tryStartRealtimeSmsProcessing() async {
    try {
      final status = await Permission.sms.status;
      if (!status.isGranted) return;
      await di.getIt<RealtimeSmsProcessor>().start();
      unawaited(requestAutoImportPermissionIfNeeded());
    } catch (e, s) {
      appLogger.error('Realtime SMS start skipped', e, s);
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
      appLogger.error('Initial loads dispatch failed', e, s);
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

  Widget _buildAppTree(BuildContext _, Widget? child) {
    return ValueListenableBuilder<double>(
      valueListenable: _fontScaleNotifier,
      builder: (context, factor, _) => AppTextScale(
        factor: factor,
        child: LocaleScope(
          child: CurrencyScope(
            child: MultiBlocProvider(
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

              child: RefreshOnAuthChange(
                enabled: _initialized,
                onAuthChanged: () => _appRouter?.config.refresh(),
                child: _AppContent(
                  initialized: _initialized,
                  error: _error,
                  errorRefId: _errorRefId,
                  databaseUnreadable: _databaseUnreadable,
                  onInitLoads: _dispatchInitialLoads,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialApp(
    BuildContext context,
    ThemeMode themeMode,
    FirstDayOfWeek firstDay,
  ) {
    return MaterialApp.router(
      onGenerateTitle: (context) => t.common.appName,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,

      localizationsDelegates: [
        FirstDayMaterialLocalizationsDelegate(firstDay),
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _appRouter?.config,
      debugShowCheckedModeBanner: false,
      builder: _buildAppTree,
    );
  }

  @override
  void dispose() {
    _localeSubscription?.cancel();
    _themeModeNotifier.dispose();
    _fontScaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeModeNotifier,
        builder: (context, themeMode, _) {
          return ValueListenableBuilder<FirstDayOfWeek>(
            valueListenable: WeekStart.current,
            builder: (context, firstDay, _) =>
                _buildMaterialApp(context, themeMode, firstDay),
          );
        },
      ),
    );
  }
}

class _AppContent extends StatefulWidget {
  const _AppContent({
    required this.child,
    required this.initialized,
    required this.error,
    required this.errorRefId,
    required this.databaseUnreadable,
    required this.onInitLoads,
  });

  final Widget child;
  final bool initialized;
  final bool error;
  final String errorRefId;
  final bool databaseUnreadable;
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
      appLogger.error('Realtime SMS drain skipped', e, s);
    }
  }

  void _handleRetry() => unawaited(di.getIt<BootstrapService>().retry());

  void _handleResetLocalData() =>
      unawaited(di.getIt<BootstrapService>().resetLocalData());

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
      unawaited(_runRecurringAppOpenWork());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.error) {
      return AppErrorFallback(
        fallbackContext: AppFallbackContext.init,
        referenceId: widget.errorRefId,
        onSendFeedback: () =>
            sendFeedback(context, errorReference: widget.errorRefId),
        onRetry: _handleRetry,
        onResetLocalData: widget.databaseUnreadable
            ? _handleResetLocalData
            : null,
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
