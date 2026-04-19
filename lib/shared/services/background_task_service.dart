import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'notification_service.dart';

const backgroundScanTask = 'background_sms_scan_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == backgroundScanTask) {
      try {
        await di.initDependencies();

        final scanSmsUseCase = di.getIt<ScanSmsUseCase>();

        // Scan SMS from the last 24 hours
        final since = DateTime.now().subtract(const Duration(hours: 24));
        final result = await scanSmsUseCase(ScanSmsParams(since: since));

        return result.fold((failure) => false, (transactions) async {
          if (transactions.isNotEmpty) {
            final notificationService = di.getIt<NotificationService>();
            await notificationService.showNotification(
              title: 'New Expenses Found',
              body:
                  'Found ${transactions.length} new expenses from your messages. Tap to view and confirm.',
            );
          }
          return true;
        });
      } catch (e) {
        return false;
      }
    }
    return true;
  });
}

class BackgroundTaskService {
  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  Future<void> scheduleDailyScan() async {
    await Workmanager().registerPeriodicTask(
      'daily_sms_scan',
      backgroundScanTask,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
}
