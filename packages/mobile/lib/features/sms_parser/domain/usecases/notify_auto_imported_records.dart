import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';
import '../entities/auto_imported_record.dart';

class NotifyAutoImportedRecords {
  final GetSettings getSettings;
  final NotificationService notificationService;

  NotifyAutoImportedRecords({
    required this.getSettings,
    required this.notificationService,
  });

  Future<void> call(List<AutoImportedRecord> records) async {
    if (records.isEmpty) return;

    try {
      final result = await getSettings(NoParams());
      final settings = result.fold((_) => null, (s) => s);
      if (settings == null ||
          !settings.isEnabled(NotificationToggle.autoImport)) {
        return;
      }

      if (!await notificationService.canNotify()) return;

      await _show(records);
    } catch (e, s) {
      appLogger.error('Error sending auto-import notification', e, s);
    }
  }

  Future<void> _show(List<AutoImportedRecord> records) async {
    if (records.length > 1) {
      await notificationService.showAutoImportSummary(count: records.length);

      return;
    }

    await notificationService.showAutoImportedRecord(records.single);
  }
}
