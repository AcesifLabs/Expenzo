import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';

class MockRecordDao extends Mock implements RecordDao {}

class MockCategoryDao extends Mock implements CategoryDao {}

void main() {
  late MockRecordDao mockRecordDao;
  late MockCategoryDao mockCategoryDao;
  late ReportsRepositoryImpl repository;

  setUpAll(() {
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  });

  setUp(() {
    mockRecordDao = MockRecordDao();
    mockCategoryDao = MockCategoryDao();
    repository = ReportsRepositoryImpl(
      recordDao: mockRecordDao,
      categoryDao: mockCategoryDao,
    );
  });

  group('ReportsRepositoryImpl', () {
    group('getSpendingTrend', () {
      test('returns Left(Failure) on exception', () async {
        when(
          () => mockRecordDao.getSpendingTrend(any(), any()),
        ).thenThrow(Exception('DB error'));

        final result = await repository.getSpendingTrend(
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
          granularity: Granularity.monthly,
        );

        expect(result.isLeft(), true);
      });
    });

    group('getCategoryBreakdown', () {
      test('returns Left(Failure) on exception', () async {
        when(
          () => mockRecordDao.getCategoryBreakdown(any(), any()),
        ).thenThrow(Exception('DB error'));

        final result = await repository.getCategoryBreakdown(
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
        );

        expect(result.isLeft(), true);
      });
    });
  });
}
