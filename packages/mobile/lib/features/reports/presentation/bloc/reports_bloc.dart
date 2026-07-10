import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import '../../domain/entities/granularity.dart';
import '../../domain/usecases/get_spending_trend.dart';
import '../../domain/usecases/get_category_breakdown.dart';
import '../../domain/usecases/get_spending_insights.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetSpendingTrend getSpendingTrend;
  final GetCategoryBreakdown getCategoryBreakdown;
  final GetSpendingInsights getSpendingInsights;

  DateTime _startDate;
  DateTime _endDate;
  Granularity _granularity;

  ReportsBloc({
    required this.getSpendingTrend,
    required this.getCategoryBreakdown,
    required this.getSpendingInsights,
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  }) : _startDate = startDate,
       _endDate = endDate,
       _granularity = granularity,
       super(ReportsInitial()) {
    on<LoadReports>(_onLoadReports, transformer: restartable());
    on<ChangeDateRange>(_onChangeDateRange, transformer: restartable());
    on<ChangeGranularity>(_onChangeGranularity, transformer: restartable());

    add(
      LoadReports(
        startDate: startDate,
        endDate: endDate,
        granularity: granularity,
      ),
    );
  }

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());

    _startDate = event.startDate;
    _endDate = event.endDate;
    _granularity = event.granularity;

    await _loadReportsData(emit);
  }

  Future<void> _onChangeDateRange(
    ChangeDateRange event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());

    _startDate = event.startDate;
    _endDate = event.endDate;

    await _loadReportsData(emit);
  }

  Future<void> _onChangeGranularity(
    ChangeGranularity event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());

    _granularity = event.granularity;

    await _loadReportsData(emit);
  }

  Future<void> _loadReportsData(Emitter<ReportsState> emit) async {
    final trendResult = await getSpendingTrend(
      startDate: _startDate,
      endDate: _endDate,
      granularity: _granularity,
    );

    final breakdownResult = await getCategoryBreakdown(
      startDate: _startDate,
      endDate: _endDate,
    );

    final insightsResult = await getSpendingInsights(
      startDate: _startDate,
      endDate: _endDate,
    );

    trendResult.fold(
      (failure) => emit(ReportsError(message: failure.message)),
      (trend) {
        breakdownResult.fold(
          (failure) => emit(ReportsError(message: failure.message)),
          (breakdown) {
            insightsResult.fold(
              (failure) => emit(ReportsError(message: failure.message)),
              (insights) => emit(
                ReportsLoaded(
                  spendingTrend: trend,
                  categoryBreakdown: breakdown,
                  insights: insights,
                  startDate: _startDate,
                  endDate: _endDate,
                  granularity: _granularity,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
