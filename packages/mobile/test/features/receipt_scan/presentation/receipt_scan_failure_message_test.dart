import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/receipt_scan/domain/usecases/extract_receipt.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/pages/receipt_scan_camera_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../support/pump_localized.dart';
import '../../../support/receipt_camera.dart';

class _MockExtractReceipt extends Mock implements ExtractReceipt {}

class _FakeImagePicker extends ImagePickerPlatform
    with MockPlatformInterfaceMixin {
  final String path;

  _FakeImagePicker(this.path);

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async => XFile(path);
}

void main() {
  setUpAll(
    () => registerFallbackValue(
      ExtractReceiptParams(imageBytes: Uint8List(0), mimeType: 'image/jpeg'),
    ),
  );

  tearDown(clearCameraPermissionMock);

  Future<void> readFails(WidgetTester tester, Failure failure) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async => switch (call.method) {
            'requestPermissions' => {1: 0},
            'checkPermissionStatus' => 0,
            _ => null,
          },
        );
    final dir = Directory.systemTemp.createTempSync('receipt');
    addTearDown(() => dir.deleteSync(recursive: true));
    final photo = File('${dir.path}/receipt.jpg')..writeAsBytesSync([1, 2]);
    ImagePickerPlatform.instance = _FakeImagePicker(photo.path);
    final extract = _MockExtractReceipt();
    when(() => extract(any())).thenAnswer((_) async => Left(failure));

    await pumpLocalized(tester, ReceiptScanCameraPage(extractReceipt: extract));
    await pumpPastTransitions(tester);
    await tester.runAsync(() async {
      await tester.tap(find.text('Choose from gallery'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await pumpPastTransitions(tester);
  }

  final cases = <String, (Failure, String Function())>{
    'an unreadable total asks for a clearer photo': (
      const ReceiptTotalUnreadableFailure(),
      () => t.receiptScan.totalUnreadable,
    ),
    'a broken reading service says so': (
      const ReceiptServiceUnavailableFailure(message: '404'),
      () => t.receiptScan.serviceUnavailable,
    ),
    'any other failure keeps the generic message': (
      const ServerFailure(message: 'not json'),
      () => t.receiptScan.readFailed,
    ),
  };

  cases.forEach((name, value) {
    final (failure, message) = value;

    testWidgets(name, (tester) async {
      await readFails(tester, failure);

      expect(find.text(message()), findsOneWidget);
    });
  });
}
