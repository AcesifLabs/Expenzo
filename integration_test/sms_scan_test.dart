import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_state.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_types.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules.dart'
    as eval;
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';

class MockSmsLocalDatasource extends Mock implements SmsLocalDatasource {}

class MockEvaluateRulesUseCase extends Mock
    implements eval.EvaluateRulesUseCase {}

class MockRecordRepository extends Mock implements RecordRepository {}

class MockCreateRecords extends Mock implements CreateRecordsFromParsedList {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SMS Scan Integration Tests', () {
    late MockSmsLocalDatasource mockSmsDatasource;
    late MockEvaluateRulesUseCase mockEvaluateRules;
    late MockRecordRepository mockRecordRepository;
    late MockCreateRecords mockCreateRecords;
    late ScanSmsUseCase scanSmsUseCase;
    late SmsScannerBloc smsScannerBloc;

    setUp(() {
      mockSmsDatasource = MockSmsLocalDatasource();
      mockEvaluateRules = MockEvaluateRulesUseCase();
      mockRecordRepository = MockRecordRepository();
      mockCreateRecords = MockCreateRecords();
      scanSmsUseCase = ScanSmsUseCase(
        smsDatasource: mockSmsDatasource,
        evaluateRules: mockEvaluateRules,
      );
      smsScannerBloc = SmsScannerBloc(
        scanSmsUseCase: scanSmsUseCase,
        recordRepository: mockRecordRepository,
        createRecordsFromParsedList: mockCreateRecords,
      );
    });

    // ... (rest of the file with search/replace)
  });
}
