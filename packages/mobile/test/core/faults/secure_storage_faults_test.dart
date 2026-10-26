import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnreadableStorage extends TestFlutterSecureStoragePlatform {
  _UnreadableStorage() : super({'jwt_access_token': 'token'});

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) => Future.error(
    PlatformException(code: 'Exception', message: 'BadPaddingException'),
  );
}

void main() {
  setUp(() => FlutterSecureStoragePlatform.instance = _UnreadableStorage());
  tearDown(() => FlutterSecureStorage.setMockInitialValues({}));

  test('an unreadable token means signed out, not a crash', () async {
    expect(await TokenStorage.getToken(), isNull);
    expect(await TokenStorage.hasToken(), isFalse);
  });

  test('unreadable sync state starts sync over', () async {
    expect(await TokenStorage.getLastSyncAt(), isNull);
    expect(await TokenStorage.isFirstSync(), isTrue);
  });
}
