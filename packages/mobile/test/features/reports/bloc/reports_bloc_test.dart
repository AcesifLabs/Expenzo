import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/reports/domain/entities/spending_insights.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_trend.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_category_breakdown.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_insights.dart';
import 'package:expense_tracker/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:expense_tracker/features/reports/presentation/bloc/reports_event.dart';
import 'package:expense_tracker/features/reports/presentation/bloc/reports_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class MockGetSpendingTrend extends Mock implements GetSpendingTrend {}

class MockGetCategoryBreakdown extends Mock implements GetCategoryBreakdown {}

class MockGetSpendingInsights extends Mock implements GetSpendingInsights {}

void main() {
  late MockGetSpendingTrend mockGetSpendingTrend;
  late MockGetCategoryBreakdown mockGetCategoryBreakdown;
  late MockGetSpendingInsights mockGetSpendingInsights;
  late ReportsBloc bloc;

  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 0);

  setUpAll(() {
    registerFallbackValue(Granularity.monthly);
  });

  setUp(() {
    mockGetSpendingTrend = MockGetSpendingTrend();
    mockGetCategoryBreakdown = MockGetCategoryBreakdown();
    mockGetSpendingInsights = MockGetSpendingInsights();
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadReports (auto-triggered in constructor)', () {
    test(
      'emits [ReportsLoading, ReportsLoaded] when all usecases succeed',
      () async {
        when(
          () => mockGetSpendingTrend(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            granularity: any(named: 'granularity'),
          ),
        ).thenAnswer((_) async => Right(const []));
        when(
          () => mockGetCategoryBreakdown(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(const []));
        when(
          () => mockGetSpendingInsights(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer(
          (_) async => Right(
            const SpendingInsights(
              highestDayAmount: 0,
              avgDailySpending: 0,
              totalTransactionCount: 0,
              totalSpent: 0,
            ),
          ),
        );

        bloc = ReportsBloc(
          getSpendingTrend: mockGetSpendingTrend,
          getCategoryBreakdown: mockGetCategoryBreakdown,
          getSpendingInsights: mockGetSpendingInsights,
          startDate: startDate,
          endDate: endDate,
          granularity: Granularity.monthly,
        );

        await expectLater(
          bloc.stream,
          emitsInOrder([isA<ReportsLoading>(), isA<ReportsLoaded>()]),
        );

        bloc.close();
      },
    );

    blocTest<ReportsBloc, ReportsState>(
      'emits loading, then the storage message when the trend fails',
      setUp: () {
        when(
          () => mockGetSpendingTrend(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            granularity: any(named: 'granularity'),
          ),
        ).thenAnswer((_) async => Left(CacheFailure(message: 'Trend failed')));
        when(
          () => mockGetCategoryBreakdown(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(const []));
        when(
          () => mockGetSpendingInsights(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer(
          (_) async => Right(
            const SpendingInsights(
              highestDayAmount: 0,
              avgDailySpending: 0,
              totalTransactionCount: 0,
              totalSpent: 0,
            ),
          ),
        );
      },
      build: () => ReportsBloc(
        getSpendingTrend: mockGetSpendingTrend,
        getCategoryBreakdown: mockGetCategoryBreakdown,
        getSpendingInsights: mockGetSpendingInsights,
        startDate: startDate,
        endDate: endDate,
        granularity: Granularity.monthly,
      ),
      expect: () => [
        isA<ReportsLoading>(),
        isA<ReportsError>().having(
          (s) => s.message,
          'message',
          t.common.errors.storage,
        ),
      ],
    );

    test('reloads the same length of range, ending now', () async {
      when(
        () => mockGetSpendingTrend(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          granularity: any(named: 'granularity'),
        ),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockGetCategoryBreakdown(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockGetSpendingInsights(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          SpendingInsights(
            highestDayAmount: 0,
            avgDailySpending: 0,
            totalTransactionCount: 0,
            totalSpent: 0,
          ),
        ),
      );

      final openedEnd = DateTime.now().subtract(const Duration(days: 1));
      final openedStart = openedEnd.subtract(const Duration(days: 30));
      bloc = ReportsBloc(
        getSpendingTrend: mockGetSpendingTrend,
        getCategoryBreakdown: mockGetCategoryBreakdown,
        getSpendingInsights: mockGetSpendingInsights,
        startDate: openedStart,
        endDate: openedEnd,
        granularity: Granularity.daily,
      );
      await bloc.stream.firstWhere((s) => s is ReportsLoaded);

      final before = DateTime.now();
      bloc.add(const RefreshReports());
      final refreshed =
          await bloc.stream.firstWhere((s) => s is ReportsLoaded)
              as ReportsLoaded;

      expect(refreshed.endDate.isBefore(before), isFalse);
      expect(
        refreshed.endDate.difference(refreshed.startDate),
        const Duration(days: 30),
      );
    });
  });
}
