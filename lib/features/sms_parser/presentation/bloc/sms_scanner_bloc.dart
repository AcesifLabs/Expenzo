import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/usecase.dart';
import '../../../expenses/domain/usecases/get_expenses.dart';
import '../../domain/usecases/scan_sms_usecase.dart';
import 'sms_scanner_event.dart';
import 'sms_scanner_state.dart';

class SmsScannerBloc extends Bloc<SmsScannerEvent, SmsScannerState> {
  final ScanSmsUseCase scanSmsUseCase;
  final GetExpenses getExpenses;

  SmsScannerBloc({required this.scanSmsUseCase, required this.getExpenses})
    : super(SmsScannerInitial()) {
    on<StartScan>(_onStartScan);
    on<ToggleSelection>(_onToggleSelection);
    on<SelectAll>(_onSelectAll);
    on<DeselectAll>(_onDeselectAll);
    on<ClearResults>(_onClearResults);
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<SmsScannerState> emit,
  ) async {
    emit(
      const SmsScannerScanning(processedMessages: 0, totalMessages: 0),
    );

    final result = await scanSmsUseCase(ScanSmsParams(since: event.since));

    await result.fold(
      (failure) async {
        emit(SmsScannerError(message: failure.message));
      },
      (transactions) async {
        if (event.filterDuplicates) {
          final expensesResult = await getExpenses(GetExpensesParams());
          final existingIds = expensesResult
              .getOrElse(() => [])
              .map((e) => e.sourceId)
              .toSet();

          final filteredTransactions = transactions
              .where((t) => !existingIds.contains(t.sourceId))
              .toList();
          emit(
            SmsScannerScanComplete(
              results: filteredTransactions,
              selectedIds: filteredTransactions.map((t) => t.sourceId).toSet(),
              lastScanTimestamp: DateTime.now(),
            ),
          );
        } else {
          emit(
            SmsScannerScanComplete(
              results: transactions,
              selectedIds: transactions.map((t) => t.sourceId).toSet(),
              lastScanTimestamp: DateTime.now(),
            ),
          );
        }
      },
    );
  }
  void _onClearResults(ClearResults event, Emitter<SmsScannerState> emit) {
    emit(SmsScannerInitial());
  }

  void _onToggleSelection(
    ToggleSelection event,
    Emitter<SmsScannerState> emit,
  ) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      final newSelectedIds = Set<String>.from(currentState.selectedIds);
      if (newSelectedIds.contains(event.transactionId)) {
        newSelectedIds.remove(event.transactionId);
      } else {
        newSelectedIds.add(event.transactionId);
      }
      emit(currentState.copyWith(selectedIds: newSelectedIds));
    }
  }

  void _onSelectAll(SelectAll event, Emitter<SmsScannerState> emit) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      final allIds = currentState.results.map((r) => r.sourceId).toSet();
      emit(currentState.copyWith(selectedIds: allIds));
    }
  }

  void _onDeselectAll(DeselectAll event, Emitter<SmsScannerState> emit) {
    final currentState = state;
    if (currentState is SmsScannerScanComplete) {
      emit(currentState.copyWith(selectedIds: {}));
    }
  }
}
