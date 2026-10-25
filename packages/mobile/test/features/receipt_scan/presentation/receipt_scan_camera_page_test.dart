import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/receipt_scan/domain/entities/receipt_extraction.dart';
import 'package:expense_tracker/features/receipt_scan/domain/usecases/extract_receipt.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/pages/receipt_scan_camera_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../support/pump_localized.dart';
import '../../../support/receipt_camera.dart';

class _MockExtractReceipt extends Mock implements ExtractReceipt {}

/// Returns [path] for every gallery pick.
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

  testWidgets('a camera refused for good offers Settings', (tester) async {
    mockCameraPermissionPermanentlyDenied();

    await pumpLocalized(tester, const ReceiptScanCameraPage());
    await pumpPastTransitions(tester);

    expect(find.textContaining('Turn it on in Settings'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('a camera refused once asks again, without Settings', (
    tester,
  ) async {
    mockCameraPermissionDenied();

    await pumpLocalized(tester, const ReceiptScanCameraPage());
    await pumpPastTransitions(tester);

    expect(
      find.text('Camera permission is required to scan receipts.'),
      findsOneWidget,
    );
    expect(find.text('Open settings'), findsNothing);
  });

  testWidgets('coming back after refusing does not ask again', (tester) async {
    // Android's dialog makes the app inactive, then resumed when answered.
    var requests = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async {
            if (call.method == 'requestPermissions') {
              requests++;

              return {1: 0};
            }

            return call.method == 'checkPermissionStatus' ? 0 : null;
          },
        );

    await pumpLocalized(tester, const ReceiptScanCameraPage());
    await pumpPastTransitions(tester);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpPastTransitions(tester);

    expect(requests, 1);
    expect(
      find.text('Camera permission is required to scan receipts.'),
      findsOneWidget,
    );
  });

  testWidgets('a receipt that fails to read while in the background brings '
      'the camera back', (tester) async {
    var statusChecks = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async {
            if (call.method == 'requestPermissions') return {1: 0};
            if (call.method == 'checkPermissionStatus') statusChecks++;

            return call.method == 'checkPermissionStatus' ? 0 : null;
          },
        );
    final dir = Directory.systemTemp.createTempSync('receipt');
    addTearDown(() => dir.deleteSync(recursive: true));
    final photo = File('${dir.path}/receipt.jpg')..writeAsBytesSync([1, 2]);
    ImagePickerPlatform.instance = _FakeImagePicker(photo.path);
    final reading = Completer<Either<Failure, ReceiptExtraction>>();
    final extract = _MockExtractReceipt();
    var started = false;
    when(() => extract(any())).thenAnswer((_) {
      started = true;

      return reading.future;
    });

    await pumpLocalized(tester, ReceiptScanCameraPage(extractReceipt: extract));
    await pumpPastTransitions(tester);
    // Reading the picked file is real I/O.
    await tester.runAsync(() async {
      await tester.tap(find.text('Choose from gallery'));
      while (!started) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    final checksBeforeFailure = statusChecks;

    reading.complete(const Left(ServerFailure(message: 'unreadable')));
    await pumpPastTransitions(tester);

    expect(statusChecks, checksBeforeFailure + 1);
  });
}
