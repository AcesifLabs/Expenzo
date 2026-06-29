import 'package:workmanager/workmanager.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'notification_service.dart';

const backgroundScanTask = 'background_sms_scan_task';

Future<bool> _handleScanTask() async {
  await di.initDependencies();

  final scanSmsUseCase = di.getIt<ScanSmsUseCase>();
  final since = DateTime.now().subtract(const Duration(hours: 24));
  final result = await scanSmsUseCase(ScanSmsParams(since: since));

  return result.fold((failure) => false, (transactions) {
    if (transactions.isEmpty) return true;

    final notificationService = di.getIt<NotificationService>();
    notificationService.showNotification(
      title: 'New Expenses Found',
      body:
          'Found ${transactions.length} new expenses from your messages. Tap to view and confirm.',
    );

    return true;
  });
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != backgroundScanTask) return true;

    try {
      return await _handleScanTask();
    } catch (e) {
      return false;
    }
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
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
      ),
    );
  }
}
