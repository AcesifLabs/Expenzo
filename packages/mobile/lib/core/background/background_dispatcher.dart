import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'package:expense_tracker/core/config/load_env.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/i18n/plural_resolvers.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';
import 'background_task_runner.dart';
import 'background_work.dart';

@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask(_runInBackground);
}

void applyBackgroundSettings(UserSettings settings) {
  final languageCode = settings.languageCode;
  final locale = languageCode == 'system'
      ? LocaleSettings.useDeviceLocaleSync()
      : LocaleSettings.setLocaleRawSync(languageCode);
  Intl.defaultLocale = locale.languageTag;
  CurrencyFormatter.current.value = CurrencyConfig.byCode(
    settings.currencyCode,
  );
  CurrencyFormatter.displayFormat.value = NumberDisplayFormat(
    decimalPlaces: settings.decimalPlaces,
    grouping: settings.digitGrouping,
  );
  WeekStart.apply(settings.effectiveFirstDayOfWeek(locale.languageCode));
}

Future<bool> _runInBackground(String task, Map<String, dynamic>? _) async {
  try {
    registerPluralResolvers();
    await initializeDateFormatting();
    DateFormat.useNativeDigitsByDefaultFor(AppLocale.bn.languageTag, false);
    await loadEnv();

    await di.initDependencies();
    await NotificationService().initialize();
    WorkmanagerBackgroundWork.markReadyInBackground();

    final result = await di.getIt<GetSettings>()(NoParams());
    final settings = result.fold((_) => null, (s) => s);
    if (settings != null) applyBackgroundSettings(settings);

    return di.getIt<BackgroundTaskRunner>().run(task);
  } catch (e, s) {
    appLogger.error('Background setup for $task failed', e, s);

    return false;
  }
}
