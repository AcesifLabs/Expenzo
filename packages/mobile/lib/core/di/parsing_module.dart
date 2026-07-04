import 'package:get_it/get_it.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart' as fsms;
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/parsing_rule_dao.dart';
import 'package:expense_tracker/core/database/daos/message_template_dao.dart';
import 'package:expense_tracker/features/parsing_rules/domain/repositories/parsing_rules_repository.dart';
import 'package:expense_tracker/features/parsing_rules/data/datasources/parsing_rules_local_datasource.dart';
import 'package:expense_tracker/features/parsing_rules/data/repositories/parsing_rules_repository_impl.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules_use_case.dart';
import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';
import 'package:expense_tracker/features/message_templates/data/datasources/message_template_local_datasource.dart';
import 'package:expense_tracker/features/message_templates/data/repositories/message_template_repository_impl.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/get_message_sources.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/save_message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/get_templates_for_source.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/save_template.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sample_analyzer_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_bloc.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/features/sms_parser/data/services/method_channel_realtime_sms_listener.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/realtime_sms_listener.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'package:expense_tracker/features/sms_parser/application/realtime_sms_processor.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';

void initParsingModule(GetIt getIt) {
  _initParsingInfrastructure(getIt);
  _initMessageTemplates(getIt);
  _initSmsParsing(getIt);
}

void _initParsingInfrastructure(GetIt getIt) {
  getIt.registerLazySingleton<ParsingIsolateService>(
    () => ParsingIsolateService(),
  );
  getIt.registerLazySingleton<ParsingRuleDao>(
    () => ParsingRuleDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ParsingRulesLocalDatasource>(
    () => ParsingRulesLocalDatasourceImpl(getIt<ParsingRuleDao>()),
  );
  getIt.registerLazySingleton<ParsingRulesRepository>(
    () => ParsingRulesRepositoryImpl(
      localDatasource: getIt<ParsingRulesLocalDatasource>(),
    ),
  );
}

void _initMessageTemplates(GetIt getIt) {
  getIt.registerLazySingleton<MessageTemplateLocalDatasource>(
    () => MessageTemplateLocalDatasourceImpl(getIt<MessageTemplateDao>()),
  );
  getIt.registerLazySingleton<MessageTemplateRepository>(
    () =>
        MessageTemplateRepositoryImpl(getIt<MessageTemplateLocalDatasource>()),
  );
  getIt.registerLazySingleton(
    () => GetMessageSources(getIt<MessageTemplateRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveMessageSource(getIt<MessageTemplateRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTemplatesForSource(getIt<MessageTemplateRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveTemplate(getIt<MessageTemplateRepository>()),
  );
  getIt.registerFactory<MessageSourcesBloc>(
    () => MessageSourcesBloc(
      getMessageSources: getIt<GetMessageSources>(),
      saveMessageSource: getIt<SaveMessageSource>(),
    ),
  );
  getIt.registerFactory<ContactSelectorBloc>(
    () => ContactSelectorBloc(smsDatasource: getIt<SmsLocalDatasource>()),
  );
  getIt.registerFactory<SampleAnalyzerBloc>(
    () => SampleAnalyzerBloc(smsDatasource: getIt<SmsLocalDatasource>()),
  );
  getIt.registerFactory<TemplateEditorBloc>(
    () => TemplateEditorBloc(
      saveTemplateUseCase: getIt<SaveTemplate>(),
      repository: getIt<MessageTemplateRepository>(),
    ),
  );
}

void _initSmsParsing(GetIt getIt) {
  getIt.registerLazySingleton(
    () => EvaluateRulesUseCase(
      getIt<ParsingRulesRepository>(),
      getIt<MessageTemplateRepository>(),
    ),
  );

  getIt.registerLazySingleton<SmsLocalDatasource>(
    () => SmsLocalDatasourceImpl(smsQuery: fsms.SmsQuery()),
  );
  getIt.registerLazySingleton(
    () => ScanSmsUseCase(
      smsDatasource: getIt<SmsLocalDatasource>(),
      evaluateRules: getIt<EvaluateRulesUseCase>(),
      parsingIsolateService: getIt<ParsingIsolateService>(),
    ),
  );
  getIt.registerFactory<SmsScannerBloc>(
    () => SmsScannerBloc(
      scanSmsUseCase: getIt<ScanSmsUseCase>(),
      recordRepository: getIt<RecordRepository>(),
      createRecordsFromParsedList: getIt<CreateRecordsFromParsedList>(),
      getBudgetsWithProgress: getIt<GetBudgetsWithProgress>(),
    ),
  );

  getIt.registerLazySingleton<RealtimeSmsListener>(
    () => MethodChannelRealtimeSmsListener(),
  );
  getIt.registerLazySingleton(
    () => RealtimeSmsProcessor(
      listener: getIt<RealtimeSmsListener>(),
      evaluateRules: getIt<EvaluateRulesUseCase>(),
      parsingIsolateService: getIt<ParsingIsolateService>(),
      recordRepository: getIt<RecordRepository>(),
      createRecordsFromParsedList: getIt<CreateRecordsFromParsedList>(),
    ),
  );
}
