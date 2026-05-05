import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/usecases/get_dashboard_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase getDashboardSummary;

  DashboardBloc({required this.getDashboardSummary})
    : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<ChangeDateRange>(_onChangeDateRange);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading(dateRange: event.dateRange));

    final result = await getDashboardSummary(event.dateRange);

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (summary) =>
          emit(DashboardLoaded(summary: summary, dateRange: event.dateRange)),
    );
  }

  Future<void> _onChangeDateRange(
    ChangeDateRange event,
    Emitter<DashboardState> emit,
  ) async {
    final dateRange = DateRange(preset: event.preset);
    add(LoadDashboard(dateRange: dateRange));
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      add(LoadDashboard(dateRange: currentState.dateRange));
    } else {
      add(LoadDashboard(dateRange: DateRange.thisMonth()));
    }
  }
}
