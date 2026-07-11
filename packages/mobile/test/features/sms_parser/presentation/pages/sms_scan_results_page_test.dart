import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_state.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_submission_status.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_view_mode.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_results_page.dart';

import '../../../../support/factories/sms_scan_result_item_factory.dart';

class _MockScanSmsUseCase extends Mock implements ScanSmsUseCase {}

class _MockRecordRepository extends Mock implements RecordRepository {}

class _MockCreateRecordsFromParsedList extends Mock
    implements CreateRecordsFromParsedList {}

class _MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

class _TestSmsScannerBloc extends SmsScannerBloc {
  _TestSmsScannerBloc()
    : super(
        scanSmsUseCase: _MockScanSmsUseCase(),
        recordRepository: _MockRecordRepository(),
        createRecordsFromParsedList: _MockCreateRecordsFromParsedList(),
        getBudgetsWithProgress: _mockBudgets(),
      );

  static _MockGetBudgetsWithProgress _mockBudgets() {
    final mock = _MockGetBudgetsWithProgress();
    when(() => mock()).thenAnswer((_) async => const Right(<BudgetProgress>[]));

    return mock;
  }

  void emitState(SmsScannerState state) => emit(state);
}

void main() {
  Widget wrapWithBloc(SmsScannerBloc bloc) {
    return MaterialApp(
      home: BlocProvider.value(value: bloc, child: const SmsScanResultsPage()),
    );
  }

  testWidgets('renders grouped sender sections in grouped mode', (
    tester,
  ) async {
    final first = makeSmsScanResultItem(
      sourceId: 'a',
      senderKey: 'BANK_A',
      senderLabel: 'Bank A',
    ).copyWith(parsedTransactionDate: DateTime(2026, 7, 11));
    final second = makeSmsScanResultItem(
      sourceId: 'b',
      senderKey: 'BANK_B',
      senderLabel: 'Bank B',
    ).copyWith(parsedTransactionDate: DateTime(2026, 7, 10));
    final bloc = _TestSmsScannerBloc();

    await tester.pumpWidget(wrapWithBloc(bloc));
    bloc.emitState(
      SmsScannerScanComplete(
        results: [first, second],
        selectedIds: {'a'},
        lastScanTimestamp: DateTime(2026, 7, 11),
      ),
    );
    await tester.pump();

    expect(find.text('Bank A'), findsOneWidget);
    expect(find.text('Bank B'), findsOneWidget);
    expect(find.byKey(const Key('sender_mode_chip')), findsOneWidget);
    expect(find.text('Create 1 Selected'), findsOneWidget);
  });

  testWidgets('shows flat list chip label in flat list mode', (tester) async {
    final first = makeSmsScanResultItem(sourceId: 'a', senderLabel: 'Bank A');
    final bloc = _TestSmsScannerBloc();

    await tester.pumpWidget(wrapWithBloc(bloc));
    bloc.emitState(
      SmsScannerScanComplete(
        results: [first],
        selectedIds: {'a'},
        lastScanTimestamp: DateTime(2026, 7, 11),
        viewMode: SmsScannerViewMode.flatList,
      ),
    );
    await tester.pump();

    expect(find.text('Flat List'), findsOneWidget);
  });

  testWidgets('shows inline submission failure message', (tester) async {
    final first = makeSmsScanResultItem(sourceId: 'a', senderLabel: 'Bank A');
    final bloc = _TestSmsScannerBloc();

    await tester.pumpWidget(wrapWithBloc(bloc));
    bloc.emitState(
      SmsScannerScanComplete(
        results: [first],
        selectedIds: {'a'},
        lastScanTimestamp: DateTime(2026, 7, 11),
        submissionStatus: SmsScannerSubmissionStatus.failure,
        submissionErrorMessage: 'create failed',
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('scan_submission_error_message')),
      findsOneWidget,
    );
    expect(find.text('create failed'), findsOneWidget);
  });

  testWidgets('does not pop page while submission is in progress', (
    tester,
  ) async {
    final bloc = _TestSmsScannerBloc();

    await tester.pumpWidget(wrapWithBloc(bloc));
    bloc.emitState(
      SmsScannerScanComplete(
        results: [makeSmsScanResultItem(sourceId: 'a')],
        selectedIds: {'a'},
        lastScanTimestamp: DateTime(2026, 7, 11),
        submissionStatus: SmsScannerSubmissionStatus.submitting,
      ),
    );
    await tester.pump();

    expect(find.text('Create 1 Selected'), findsOneWidget);
    expect(find.text('Create 1 Selected'), findsWidgets);
  });
}
