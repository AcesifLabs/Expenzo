import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_state.dart';

class MockScanSmsUseCase extends Mock implements ScanSmsUseCase {}

class MockRecordRepository extends Mock implements RecordRepository {}

class MockCreateRecordsFromParsedList extends Mock
    implements CreateRecordsFromParsedList {}

class MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

void main() {
  late SmsScannerBloc bloc;

  setUp(() {
    bloc = SmsScannerBloc(
      scanSmsUseCase: MockScanSmsUseCase(),
      recordRepository: MockRecordRepository(),
      createRecordsFromParsedList: MockCreateRecordsFromParsedList(),
      getBudgetsWithProgress: MockGetBudgetsWithProgress(),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ToggleSelection', () {
    test('does nothing when state is not SmsScannerScanComplete', () async {
      expectLater(bloc.stream, neverEmits(isA<SmsScannerScanComplete>()));
      bloc.add(const ToggleSelection(transactionId: 'tx-1'));
      await Future.delayed(Duration.zero);
    });
  });

  group('ClearResults', () {
    test('resets to SmsScannerInitial', () async {
      final expected = [isA<SmsScannerInitial>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(ClearResults());
    });
  });

  group('DeselectAll', () {
    test('does nothing when state is not SmsScannerScanComplete', () async {
      expectLater(bloc.stream, neverEmits(isA<SmsScannerScanComplete>()));
      bloc.add(DeselectAll());
      await Future.delayed(Duration.zero);
    });
  });
}
