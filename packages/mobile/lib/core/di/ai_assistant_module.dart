import 'package:get_it/get_it.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_insights.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_category_breakdown.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_datasource.dart';
import 'package:expense_tracker/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:expense_tracker/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/build_financial_context.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/redact_ai_context.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/send_ai_message.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/validate_ai_prompt.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';

void initAiAssistantModule(GetIt getIt) {
  getIt.registerLazySingleton(() => GroqDataSource());
  getIt.registerLazySingleton<AiAssistantRepository>(
    () => AiAssistantRepositoryImpl(dataSource: getIt<GroqDataSource>()),
  );
  getIt.registerLazySingleton(() => const RedactAiContext());
  getIt.registerLazySingleton(
    () => BuildFinancialContext(
      getDashboardSummary: getIt<GetDashboardSummary>(),
      getSpendingInsights: getIt<GetSpendingInsights>(),
      getCategoryBreakdown: getIt<GetCategoryBreakdown>(),
      redactAiContext: getIt<RedactAiContext>(),
    ),
  );
  getIt.registerLazySingleton(
    () => SendMessageStream(repository: getIt<AiAssistantRepository>()),
  );
  getIt.registerLazySingleton(() => const ValidateAiPrompt());
  getIt.registerFactory(
    () => AiAssistantBloc(
      buildFinancialContext: getIt<BuildFinancialContext>(),
      sendMessageStream: getIt<SendMessageStream>(),
      validateAiPrompt: getIt<ValidateAiPrompt>(),
    ),
  );
}
