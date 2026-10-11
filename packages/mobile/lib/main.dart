import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/di/injection_container.dart' as di;
import 'core/lifecycle/bootstrap_service.dart';
import 'expenzo_app.dart';
import 'i18n/strings.g.dart';
import 'shared/presentation/widgets/app_critical_error.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Device language until saved settings load (ExpenzoApp._applySettings).
  final deviceLocale = LocaleSettings.useDeviceLocaleSync();
  await initializeDateFormatting();
  // Dates keep Latin digits in Bangla, like amounts (CurrencyFormatter).
  DateFormat.useNativeDigitsByDefaultFor(AppLocale.bn.languageTag, false);
  Intl.defaultLocale = deviceLocale.languageTag;

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
