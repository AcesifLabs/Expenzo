import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

void mockCameraPermissionDenied() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        _permissionChannel,

        (call) async => call.method == 'requestPermissions' ? {1: 0} : null,
      );
}

void mockCameraPermissionPermanentlyDenied() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        _permissionChannel,

        (call) async => call.method == 'requestPermissions' ? {1: 4} : null,
      );
}

void clearCameraPermissionMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_permissionChannel, null);
}

Future<void> pumpPastTransitions(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
