import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:expense_tracker/features/settings/data/repositories/settings_repository_impl.dart';

import '../../../support/factories/user_settings_factory.dart';

class _MockDatasource extends Mock implements SettingsLocalDatasource {}

void main() {
  late _MockDatasource datasource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = SettingsRepositoryImpl(localDatasource: datasource);
  });

  group('resetSettings', () {
    test('returns the defaults', () async {
      final defaults = makeUserSettings();
      when(() => datasource.resetSettings()).thenAnswer((_) async => defaults);

      final result = await repository.resetSettings();

      expect(result.fold((_) => null, (s) => s), defaults);
    });

    test('a CacheException becomes CacheFailure', () async {
      when(
        () => datasource.resetSettings(),
      ).thenThrow(const CacheException(message: 'disk'));

      final result = await repository.resetSettings();

      expect(
        result.fold((f) => f, (_) => null),
        isA<CacheFailure>().having((f) => f.message, 'message', 'disk'),
      );
    });

    test('any other error becomes CacheFailure', () async {
      when(() => datasource.resetSettings()).thenThrow(StateError('boom'));

      final result = await repository.resetSettings();

      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });
  });
}
