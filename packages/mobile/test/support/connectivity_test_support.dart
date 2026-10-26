import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

void registerTestConnectivity() {
  if (di.getIt.isRegistered<ConnectivityService>()) return;

  final connectivity = MockConnectivityService();
  when(() => connectivity.hasNetworkLink()).thenAnswer((_) async => true);
  when(() => connectivity.checkNow()).thenAnswer((_) async => true);
  di.getIt.registerSingleton<ConnectivityService>(connectivity);
}
