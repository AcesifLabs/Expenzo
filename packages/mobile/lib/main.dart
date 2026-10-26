import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/background/background_dispatcher.dart';
import 'core/background/background_work.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/config/load_env.dart';
import 'core/di/injection_container.dart' as di;
import 'core/lifecycle/bootstrap_service.dart';
import 'core/logger/app_logger.dart';
import 'core/logger/crash_reporter.dart';
import 'expenzo_app.dart';
import 'i18n/plural_resolvers.dart';
import 'i18n/strings.g.dart';
import 'shared/presentation/widgets/inline_error_placeholder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await WorkmanagerBackgroundWork.initialize(backgroundTaskDispatcher);

  registerPluralResolvers();
  final deviceLocale = LocaleSettings.useDeviceLocaleSync();
  await initializeDateFormatting();

  DateFormat.useNativeDigitsByDefaultFor(AppLocale.bn.languageTag, false);
  Intl.defaultLocale = deviceLocale.languageTag;

  await loadEnv();

  ErrorWidget.builder = (details) => InlineErrorPlaceholder(details: details);

  FlutterError.onError = FlutterError.presentError;

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Async Error: $error\n$stack');
    }

    return true;
  };

  appLogger.configure(observer: CrashReportingTalkerObserver(crashReporter));
  Bloc.observer = const AppBlocObserver();

  di.getIt.registerSingleton<BootstrapService>(
    BootstrapService(
      remountRoot: () async => runApp(ExpenzoApp(key: UniqueKey())),
    ),
  );

  await crashReporter.start(
    dsn: dotenv.isInitialized ? dotenv.maybeGet('SENTRY_DSN') ?? '' : '',
    prefs: await SharedPreferences.getInstance(),
    appRunner: () => runApp(const ExpenzoApp()),
  );
}
