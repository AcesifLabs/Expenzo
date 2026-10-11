import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

/// Makes `Permission.camera.request()` return denied, so the receipt camera
/// page shows its permission message and never touches the camera plugin.
/// Undo with [clearCameraPermissionMock].
void mockCameraPermissionDenied() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        _permissionChannel,
        // Permission.camera is 1; PermissionStatus.denied is 0.
        (call) async => call.method == 'requestPermissions' ? {1: 0} : null,
      );
}

void clearCameraPermissionMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_permissionChannel, null);
}

/// Pumps past route transitions. The receipt camera page's sparkle animation
/// repeats forever, so `pumpAndSettle` would time out once it is on screen.
Future<void> pumpPastTransitions(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
