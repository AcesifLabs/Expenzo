import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_state.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules.dart'
    as eval;
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses.dart';

class MockSmsLocalDatasource extends Mock implements SmsLocalDatasource {}

class MockEvaluateRulesUseCase extends Mock
    implements eval.EvaluateRulesUseCase {}

class MockGetExpenses extends Mock implements GetExpenses {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SMS Scan Integration Tests', () {
    late MockSmsLocalDatasource mockSmsDatasource;
    late MockEvaluateRulesUseCase mockEvaluateRules;
    late MockGetExpenses mockGetExpenses;
    late ScanSmsUseCase scanSmsUseCase;
    late SmsScannerBloc smsScannerBloc;

    setUp(() {
      mockSmsDatasource = MockSmsLocalDatasource();
      mockEvaluateRules = MockEvaluateRulesUseCase();
      mockGetExpenses = MockGetExpenses();
      scanSmsUseCase = ScanSmsUseCase(
        smsDatasource: mockSmsDatasource,
        evaluateRules: mockEvaluateRules,
      );
      smsScannerBloc = SmsScannerBloc(
        scanSmsUseCase: scanSmsUseCase,
        getExpenses: mockGetExpenses,
      );
    });

    tearDown(() {
      smsScannerBloc.close();
    });

    testWidgets('scanSms_flow emits scanning then complete states', (
      WidgetTester tester,
    ) async {
      final testMessages = [
        SmsMessage(
          id: '1',
          address: '+919876543210',
          body: 'Your bank account is credited with Rs. 5000',
          date: DateTime(2024, 1, 15, 10, 30),
          read: false,
          type: SmsType.received,
        ),
        SmsMessage(
          id: '2',
          address: '+919876543211',
          body: 'UPI payment of Rs. 100 to merchant',
          date: DateTime(2024, 1, 15, 11, 0),
          read: false,
          type: SmsType.received,
        ),
      ];

      final testParsedTransactions = [
        ParsedTransaction(
          rawMessage: 'Your bank account is credited with Rs. 5000',
          amount: 5000.0,
          sourceType: 'sms',
          sourceId: '1',
          confidenceScore: 0.95,
          parseFailed: false,
        ),
      ];

      when(
        () => mockSmsDatasource.getSmsFromDateRange(any(), any()),
      ).thenAnswer((_) async => testMessages);
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => Right(testParsedTransactions.first));

      smsScannerBloc.add(const StartScan());

      await expectLater(
        smsScannerBloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>(),
        ]),
      );
    });

    testWidgets('selectAndCreateExpense_flow creates expense from selected', (
      WidgetTester tester,
    ) async {
      final testParsedTransactions = [
        ParsedTransaction(
          rawMessage: 'UPI payment of Rs. 500 to merchant',
          amount: 500.0,
          description: 'UPI payment',
          sourceType: 'sms',
          sourceId: 'sms_001',
          confidenceScore: 0.95,
          parseFailed: false,
        ),
      ];

      when(
        () => mockSmsDatasource.getSmsFromDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => Right(testParsedTransactions.first));

      smsScannerBloc.add(const StartScan());

      await expectLater(
        smsScannerBloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>().having(
            (s) => s.results.length,
            'results count',
            1,
          ),
        ]),
      );

      smsScannerBloc.add(const ToggleSelection(transactionId: 'sms_001'));

      await tester.pumpAndSettle();

      final state = smsScannerBloc.state;
      expect(state, isA<SmsScannerScanComplete>());
      if (state is SmsScannerScanComplete) {
        expect(state.selectedIds.contains('sms_001'), isTrue);
      }
    });

    testWidgets('duplicateDetection_flow skips same sourceId on second scan', (
      WidgetTester tester,
    ) async {
      const duplicateSourceId = '12345';

      final firstParsedTransactions = ParsedTransaction(
        rawMessage: 'First message',
        amount: 100.0,
        sourceType: 'sms',
        sourceId: duplicateSourceId,
        confidenceScore: 0.9,
        parseFailed: false,
      );

      when(
        () => mockSmsDatasource.getSmsFromDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => Right(firstParsedTransactions));

      smsScannerBloc.add(const StartScan());

      await expectLater(
        smsScannerBloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>(),
        ]),
      );

      final firstState = smsScannerBloc.state;
      expect(firstState, isA<SmsScannerScanComplete>());
      if (firstState is SmsScannerScanComplete) {
        expect(
          firstState.results
              .where((t) => t.sourceId == duplicateSourceId)
              .length,
          equals(1),
        );
      }
    });

    testWidgets('scanLargeSms_flow processes large dataset', (
      WidgetTester tester,
    ) async {
      final largeMessages = List.generate(
        1500,
        (i) => SmsMessage(
          id: '$i',
          address: '+919876543210',
          body: 'Test message $i with Rs. ${i * 10}',
          date: DateTime.now(),
          read: false,
          type: SmsType.received,
        ),
      );

      when(
        () => mockSmsDatasource.getSmsFromDateRange(any(), any()),
      ).thenAnswer((_) async => largeMessages);
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => const Right(null));

      smsScannerBloc.add(const StartScan());

      await expectLater(
        smsScannerBloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>(),
        ]),
      );

      final state = smsScannerBloc.state;
      expect(state, isA<SmsScannerScanComplete>());
    });

    testWidgets('toggleSelection_flow toggles item selection', (
      WidgetTester tester,
    ) async {
      final testParsedTransactions = [
        ParsedTransaction(
          rawMessage: 'Test message 1',
          amount: 100.0,
          sourceType: 'sms',
          sourceId: 'test_001',
          confidenceScore: 0.9,
          parseFailed: false,
        ),
        ParsedTransaction(
          rawMessage: 'Test message 2',
          amount: 200.0,
          sourceType: 'sms',
          sourceId: 'test_002',
          confidenceScore: 0.85,
          parseFailed: false,
        ),
      ];

      when(
        () => mockSmsDatasource.getSmsFromDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(() => mockEvaluateRules.call(any())).thenAnswer((invocation) async {
        final param =
            invocation.positionalArguments[0] as eval.EvaluateRulesParams;
        final found = testParsedTransactions.where(
          (t) => t.sourceId == param.sourceId,
        );
        return Right(found.isNotEmpty ? found.first : null);
      });

      smsScannerBloc.add(const StartScan());

      await expectLater(
        smsScannerBloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>(),
        ]),
      );

      smsScannerBloc.add(const ToggleSelection(transactionId: 'test_001'));
      await tester.pumpAndSettle();

      var state = smsScannerBloc.state as SmsScannerScanComplete;
      expect(state.selectedIds.contains('test_001'), isTrue);
      expect(state.selectedIds.contains('test_002'), isFalse);

      smsScannerBloc.add(const ToggleSelection(transactionId: 'test_001'));
      await tester.pumpAndSettle();

      state = smsScannerBloc.state as SmsScannerScanComplete;
      expect(state.selectedIds.contains('test_001'), isFalse);
    });

    testWidgets('selectAllDeselectAll_flow works correctly', (
      WidgetTester tester,
    ) async {
      final testParsedTransactions = List.generate(
        5,
        (i) => ParsedTransaction(
          rawMessage: 'Test message $i',
          amount: 100.0 + i,
          sourceType: 'sms',
          sourceId: 'test_00$i',
          confidenceScore: 0.9,
          parseFailed: false,
        ),
      );

      when(
        () => mockSmsDatasource.getSmsFromDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(() => mockEvaluateRules.call(any())).thenAnswer((invocation) async {
        final param =
            invocation.positionalArguments[0] as eval.EvaluateRulesParams;
        final found = testParsedTransactions.where(
          (t) => t.sourceId == param.sourceId,
        );
        return Right(found.isNotEmpty ? found.first : null);
      });

      smsScannerBloc.add(const StartScan());

      await expectLater(
        smsScannerBloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>(),
        ]),
      );

      smsScannerBloc.add(SelectAll());
      await tester.pumpAndSettle();

      var state = smsScannerBloc.state as SmsScannerScanComplete;
      expect(state.selectedIds.length, equals(5));

      smsScannerBloc.add(DeselectAll());
      await tester.pumpAndSettle();

      state = smsScannerBloc.state as SmsScannerScanComplete;
      expect(state.selectedIds.isEmpty, isTrue);
    });

    testWidgets('clearResults_flow resets state to initial', (
      WidgetTester tester,
    ) async {
      final testParsedTransactions = [
        ParsedTransaction(
          rawMessage: 'Test message',
          amount: 100.0,
          sourceType: 'sms',
          sourceId: 'test_001',
          confidenceScore: 0.9,
          parseFailed: false,
        ),
      ];

      when(
        () => mockSmsDatasource.getSmsFromDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => Right(testParsedTransactions.first));

      smsScannerBloc.add(const StartScan());

      await expectLater(
        smsScannerBloc.stream,
        emitsInOrder([
          isA<SmsScannerScanning>(),
          isA<SmsScannerScanComplete>(),
        ]),
      );

      smsScannerBloc.add(ClearResults());
      await tester.pumpAndSettle();

      expect(smsScannerBloc.state, isA<SmsScannerInitial>());
    });
  });
}
