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
import 'package:expense_tracker/features/reports/presentation/bloc/reports_state.dart';

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

    test('emits [ReportsLoading, ReportsError] when trend fails', () async {
      when(
        () => mockGetSpendingTrend(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          granularity: any(named: 'granularity'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Trend failed')));
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
        emitsInOrder([
          isA<ReportsLoading>(),
          isA<ReportsError>().having(
            (s) => s.message,
            'message',
            'Trend failed',
          ),
        ]),
      );

      bloc.close();
    });
  });
}
