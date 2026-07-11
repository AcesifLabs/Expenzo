import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_scan_page.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_submission_status.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_state.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_view_mode.dart';
import '../../../support/factories/sms_scan_result_item_factory.dart';

class MockScanSmsUseCase extends Mock implements ScanSmsUseCase {}

class MockRecordRepository extends Mock implements RecordRepository {}

class MockCreateRecordsFromParsedList extends Mock
    implements CreateRecordsFromParsedList {}

class MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

void main() {
  late MockScanSmsUseCase mockScanSmsUseCase;
  late MockCreateRecordsFromParsedList mockCreateRecordsFromParsedList;
  late MockGetBudgetsWithProgress mockGetBudgetsWithProgress;
  late SmsScannerBloc bloc;

  setUpAll(() {
    registerFallbackValue(ScanSmsParams());
  });

  setUp(() {
    mockScanSmsUseCase = MockScanSmsUseCase();
    mockCreateRecordsFromParsedList = MockCreateRecordsFromParsedList();
    mockGetBudgetsWithProgress = MockGetBudgetsWithProgress();
    when(
      () => mockGetBudgetsWithProgress(),
    ).thenAnswer((_) async => const Right(<BudgetProgress>[]));
    bloc = SmsScannerBloc(
      scanSmsUseCase: mockScanSmsUseCase,
      recordRepository: MockRecordRepository(),
      createRecordsFromParsedList: mockCreateRecordsFromParsedList,
      getBudgetsWithProgress: mockGetBudgetsWithProgress,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('StartScan', () {
    test('keeps pagination open when page says more results remain', () async {
      final scanItem = makeSmsScanResultItem(sourceId: 'source-1');
      when(() => mockScanSmsUseCase(any())).thenAnswer(
        (_) async => Right(
          SmsScanPage(
            results: [scanItem],
            nextOffset: 25,
            hasReachedMax: false,
          ),
        ),
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>()
              .having((state) => state.results, 'results', [scanItem])
              .having((state) => state.currentOffset, 'currentOffset', 25)
              .having((state) => state.hasReachedMax, 'hasReachedMax', false)
              .having((state) => state.selectedIds, 'selectedIds', {
                scanItem.sourceId,
              }),
        ]),
      );

      bloc.add(
        StartScan(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 11),
          filterDuplicates: false,
        ),
      );

      await expectation;

      final captured =
          verify(() => mockScanSmsUseCase(captureAny())).captured.single
              as ScanSmsParams;
      expect(captured.startDate, DateTime(2026, 7, 1));
      expect(captured.endDate, DateTime(2026, 7, 11));
      expect(captured.offset, 0);
      expect(captured.limit, 10);
    });

    test('emits error when scan use case fails', () async {
      when(() => mockScanSmsUseCase(any())).thenAnswer(
        (_) async => const Left(SmsScanFailure(message: 'scan failed')),
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerError>().having(
            (state) => state.message,
            'message',
            'scan failed',
          ),
        ]),
      );

      bloc.add(const StartScan(filterDuplicates: false));

      await expectation;
    });
  });

  group('LoadMoreScanResults', () {
    test('uses current scan bounds and appends next page', () async {
      final firstItem = makeSmsScanResultItem(sourceId: 'source-1');
      final secondItem = makeSmsScanResultItem(sourceId: 'source-2');
      var invocation = 0;

      when(() => mockScanSmsUseCase(any())).thenAnswer((_) async {
        invocation += 1;

        return Right(
          invocation == 1
              ? SmsScanPage(
                  results: [firstItem],
                  nextOffset: 12,
                  hasReachedMax: false,
                )
              : SmsScanPage(
                  results: [secondItem],
                  nextOffset: 24,
                  hasReachedMax: true,
                ),
        );
      });

      bloc.add(
        StartScan(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 11),
          filterDuplicates: false,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final expectation = expectLater(
        bloc.stream,
        emitsThrough(
          isA<SmsScannerScanComplete>()
              .having((state) => state.results.length, 'result count', 2)
              .having((state) => state.currentOffset, 'currentOffset', 24)
              .having((state) => state.hasReachedMax, 'hasReachedMax', true),
        ),
      );

      bloc.add(const LoadMoreScanResults(filterDuplicates: false));
      await expectation;

      final captured = verify(() => mockScanSmsUseCase(captureAny())).captured;
      final loadMoreParams = captured.last as ScanSmsParams;
      expect(loadMoreParams.startDate, DateTime(2026, 7, 1));
      expect(loadMoreParams.endDate, DateTime(2026, 7, 11));
      expect(loadMoreParams.offset, 12);
      expect(loadMoreParams.limit, 10);
    });
  });

  group('selection helpers', () {
    test(
      'selects and deselects a sender group without affecting other senders',
      () async {
        final senderOneFirst = makeSmsScanResultItem(
          sourceId: 'source-1',
          senderKey: 'BANK_A',
          senderLabel: 'Bank A',
        );
        final senderOneSecond = makeSmsScanResultItem(
          sourceId: 'source-2',
          senderKey: 'BANK_A',
          senderLabel: 'Bank A',
        );
        final senderTwo = makeSmsScanResultItem(
          sourceId: 'source-3',
          senderKey: 'BANK_B',
          senderLabel: 'Bank B',
        );

        when(() => mockScanSmsUseCase(any())).thenAnswer(
          (_) async => Right(
            SmsScanPage(
              results: [senderOneFirst, senderOneSecond, senderTwo],
              nextOffset: 3,
              hasReachedMax: true,
            ),
          ),
        );

        bloc.add(const StartScan(filterDuplicates: false));
        await Future<void>.delayed(Duration.zero);
        bloc.add(DeselectSenderGroup(senderKey: 'BANK_B'));

        final afterDeselect =
            await bloc.stream.firstWhere(
                  (state) =>
                      state is SmsScannerScanComplete &&
                      state.selectedIds.length == 2 &&
                      !state.selectedIds.contains('source-3'),
                )
                as SmsScannerScanComplete;
        expect(afterDeselect.selectedIds, {'source-1', 'source-2'});
        expect(afterDeselect.selectedCountForSender('BANK_A'), 2);
        expect(afterDeselect.selectedCountForSender('BANK_B'), 0);

        bloc.add(SelectSenderGroup(senderKey: 'BANK_B'));

        final afterSelect =
            await bloc.stream.firstWhere(
                  (state) =>
                      state is SmsScannerScanComplete &&
                      state.selectedIds.length == 3,
                )
                as SmsScannerScanComplete;
        expect(afterSelect.selectedIds, {'source-1', 'source-2', 'source-3'});
      },
    );

    test('updates view mode when requested', () async {
      final scanItem = makeSmsScanResultItem(sourceId: 'source-1');
      when(() => mockScanSmsUseCase(any())).thenAnswer(
        (_) async => Right(
          SmsScanPage(results: [scanItem], nextOffset: 1, hasReachedMax: true),
        ),
      );

      bloc.add(const StartScan(filterDuplicates: false));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SetViewMode(viewMode: SmsScannerViewMode.flatList));

      final state =
          await bloc.stream.firstWhere(
                (state) =>
                    state is SmsScannerScanComplete &&
                    state.viewMode == SmsScannerViewMode.flatList,
              )
              as SmsScannerScanComplete;
      expect(state.viewMode, SmsScannerViewMode.flatList);
    });
  });

  group('range and submission state', () {
    test('derives active range label from start and end date', () async {
      final scanItem = makeSmsScanResultItem(sourceId: 'source-1');
      when(() => mockScanSmsUseCase(any())).thenAnswer(
        (_) async => Right(
          SmsScanPage(results: [scanItem], nextOffset: 1, hasReachedMax: true),
        ),
      );

      bloc.add(
        StartScan(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 11),
          filterDuplicates: false,
        ),
      );

      final state =
          await bloc.stream.firstWhere(
                (state) => state is SmsScannerScanComplete,
              )
              as SmsScannerScanComplete;
      expect(state.activeRangeLabel, 'Jul 1 – Jul 11');
    });

    test(
      'keeps results visible and stores submission failure message',
      () async {
        final scanItem = makeSmsScanResultItem(sourceId: 'source-1');
        when(() => mockScanSmsUseCase(any())).thenAnswer(
          (_) async => Right(
            SmsScanPage(
              results: [scanItem],
              nextOffset: 1,
              hasReachedMax: true,
            ),
          ),
        );
        when(() => mockCreateRecordsFromParsedList(any())).thenAnswer(
          (_) async => const Left(CacheFailure(message: 'create failed')),
        );

        bloc.add(const StartScan(filterDuplicates: false));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          CreateSelectedExpenses(transactions: [scanItem.parsedTransaction]),
        );

        final submittingState =
            await bloc.stream.firstWhere(
                  (state) =>
                      state is SmsScannerScanComplete &&
                      state.submissionStatus ==
                          SmsScannerSubmissionStatus.submitting,
                )
                as SmsScannerScanComplete;
        expect(submittingState.results, [scanItem]);

        final failureState =
            await bloc.stream.firstWhere(
                  (state) =>
                      state is SmsScannerScanComplete &&
                      state.submissionStatus ==
                          SmsScannerSubmissionStatus.failure,
                )
                as SmsScannerScanComplete;
        expect(failureState.results, [scanItem]);
        expect(failureState.submissionErrorMessage, 'create failed');
      },
    );

    test('moves to success submission state on create success', () async {
      final scanItem = makeSmsScanResultItem(sourceId: 'source-1');
      when(() => mockScanSmsUseCase(any())).thenAnswer(
        (_) async => Right(
          SmsScanPage(results: [scanItem], nextOffset: 1, hasReachedMax: true),
        ),
      );
      when(() => mockCreateRecordsFromParsedList(any())).thenAnswer(
        (_) async => const Right(
          CreateRecordsResult(
            createdCount: 1,
            skippedDuplicates: 0,
            errors: [],
          ),
        ),
      );

      bloc.add(const StartScan(filterDuplicates: false));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        CreateSelectedExpenses(transactions: [scanItem.parsedTransaction]),
      );

      final successState =
          await bloc.stream.firstWhere(
                (state) =>
                    state is SmsScannerScanComplete &&
                    state.submissionStatus ==
                        SmsScannerSubmissionStatus.success,
              )
              as SmsScannerScanComplete;
      expect(successState.results, [scanItem]);
      expect(successState.submissionErrorMessage, isNull);
    });
  });
}
