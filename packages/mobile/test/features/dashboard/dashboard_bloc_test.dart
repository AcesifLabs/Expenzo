import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockGetDashboardSummary extends Mock implements GetDashboardSummary {}

void main() {
  late MockGetDashboardSummary mockGetDashboardSummary;
  late DashboardBloc bloc;
  late DateRange testDateRange;

  setUp(() {
    mockGetDashboardSummary = MockGetDashboardSummary();
    bloc = DashboardBloc(getDashboardSummary: mockGetDashboardSummary);
    testDateRange = DateRange.thisMonth();
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadDashboard', () {
    test('emits [DashboardLoading, DashboardLoaded] on success', () async {
      final summary = DashboardSummary(
        totalIncome: 5000,
        totalExpense: 3000,
        totalSpent: 3000,
        previousPeriodTotal: 2500,
        percentChange: 20,
        categoryBreakdown: const [],
        recentTransactions: const [],
      );

      when(
        () => mockGetDashboardSummary(any()),
      ).thenAnswer((_) async => Right(summary));

      final expected = [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>().having(
          (s) => s.summary.totalIncome,
          'totalIncome',
          5000,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(LoadDashboard(dateRange: testDateRange));
    });

    test('emits [DashboardLoading, DashboardError] on failure', () async {
      when(
        () => mockGetDashboardSummary(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Failed to load')));

      final expected = [
        isA<DashboardLoading>(),
        isA<DashboardError>().having(
          (s) => s.message,
          'message',
          'Failed to load',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(LoadDashboard(dateRange: testDateRange));
    });
  });
}
