import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../database/app_database.dart';
import '../database/daos/expense_dao.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/pending_recurring_dao.dart';
import '../database/daos/parsing_rule_dao.dart';
import '../database/daos/message_template_dao.dart';
import '../database/daos/budget_dao.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/categories/data/datasources/category_local_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/create_category.dart';
import '../../features/categories/domain/usecases/delete_category.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/update_category.dart';
import '../../features/categories/presentation/bloc/category_bloc.dart';
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/add_expense.dart';
import '../../features/expenses/domain/usecases/create_expense_from_parsed.dart';
import '../../features/expenses/domain/usecases/create_expenses_from_parsed_list.dart';
import '../../features/expenses/domain/usecases/delete_expense.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/update_expense.dart';
import '../../features/expenses/presentation/bloc/expense_bloc.dart';
import '../../features/parsing_rules/domain/repositories/parsing_rules_repository.dart';
import '../../features/sms_parser/data/datasources/sms_local_datasource.dart';
import '../../features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import '../../features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import '../../features/parsing_rules/domain/services/parsing_isolate_service.dart';
import '../../features/parsing_rules/domain/usecases/evaluate_rules.dart';
import '../../features/parsing_rules/data/datasources/parsing_rules_local_datasource.dart';
import '../../features/parsing_rules/data/repositories/parsing_rules_repository_impl.dart';
import '../../features/message_templates/domain/repositories/message_template_repository.dart';
import '../../features/message_templates/data/datasources/message_template_local_datasource.dart';
import '../../features/message_templates/data/repositories/message_template_repository_impl.dart';
import '../../features/message_templates/domain/usecases/get_message_sources.dart';
import '../../features/message_templates/domain/usecases/save_message_source.dart';
import '../../features/message_templates/domain/usecases/get_templates_for_source.dart';
import '../../features/message_templates/domain/usecases/save_template.dart';
import '../../features/message_templates/presentation/bloc/message_sources_bloc.dart';
import '../../features/message_templates/presentation/bloc/contact_selector_bloc.dart';
import '../../features/message_templates/presentation/bloc/sample_analyzer_bloc.dart';
import '../../features/message_templates/presentation/bloc/template_editor_bloc.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_spending_trend.dart';
import '../../features/reports/domain/usecases/get_category_breakdown.dart';
import '../../features/reports/domain/usecases/get_spending_insights.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/budgets/data/datasources/budget_local_datasource.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/domain/usecases/get_budgets.dart';
import '../../features/budgets/domain/usecases/create_budget.dart';
import '../../features/budgets/domain/usecases/update_budget.dart';
import '../../features/budgets/domain/usecases/delete_budget.dart';
import '../../features/budgets/presentation/bloc/budget_bloc.dart';

final getIt = GetIt.instance;

/// Tracks whether feature-level dependencies have been registered.
bool _featureDependenciesRegistered = false;

/// Registers ONLY the dependencies needed for the first visible screen
/// (Auth + Database + Categories + Expenses). Returns immediately so
/// the splash screen can render without waiting for the full DI graph.
Future<void> initCriticalDependencies() async {
  // ── Core Infrastructure ──
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'https://www.googleapis.com/auth/gmail.readonly',
      ],
    ),
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Database uses NativeDatabase.createInBackground — non-blocking
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // DAOs
  getIt.registerFactory<ExpenseDao>(() => ExpenseDao(getIt<AppDatabase>()));
  getIt.registerFactory<CategoryDao>(() => CategoryDao(getIt<AppDatabase>()));
  getIt.registerFactory<PendingRecurringDao>(
    () => PendingRecurringDao(getIt<AppDatabase>()),
  );
  getIt.registerFactory<MessageTemplateDao>(
    () => MessageTemplateDao(getIt<AppDatabase>()),
  );

  // ── Auth ──
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      googleSignIn: getIt<GoogleSignIn>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: getIt<AuthRemoteDatasource>()),
  );
  getIt.registerLazySingleton(() => SignInWithGoogle(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => DeleteAccount(getIt<AuthRepository>()));
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
    ),
  );

  // ── Categories (needed on first screen) ──
  getIt.registerLazySingleton<CategoryLocalDatasource>(
    () => CategoryLocalDatasourceImpl(categoryDao: getIt<CategoryDao>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      localDatasource: getIt<CategoryLocalDatasource>(),
    ),
  );
  getIt.registerLazySingleton(() => GetCategories(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
    () => CreateCategory(getIt<CategoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateCategory(getIt<CategoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteCategory(getIt<CategoryRepository>()),
  );
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      getCategories: getIt<GetCategories>(),
      createCategory: getIt<CreateCategory>(),
      updateCategory: getIt<UpdateCategory>(),
      deleteCategory: getIt<DeleteCategory>(),
    ),
  );

  // ── Expenses (needed on first screen) ──
  getIt.registerLazySingleton<ExpenseLocalDatasource>(
    () => ExpenseLocalDatasourceImpl(expenseDao: getIt<ExpenseDao>()),
  );
  getIt.registerLazySingleton<ExpenseRepository>(
    () =>
        ExpenseRepositoryImpl(localDatasource: getIt<ExpenseLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetExpenses(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => AddExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => UpdateExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => DeleteExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(
    () => CreateExpenseFromParsed(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateExpensesFromParsedList(getIt<CreateExpenseFromParsed>()),
  );
  getIt.registerFactory<ExpenseBloc>(
    () => ExpenseBloc(
      getExpenses: getIt<GetExpenses>(),
      addExpense: getIt<AddExpense>(),
      updateExpense: getIt<UpdateExpense>(),
      deleteExpense: getIt<DeleteExpense>(),
      expenseRepository: getIt<ExpenseRepository>(),
    ),
  );
}

/// Registers feature-level dependencies (Scan, Email, Parsing, Reports,
/// Budgets, Templates). Called in the background after the first frame
/// renders. Safe to call multiple times — will only register once.
Future<void> initFeatureDependencies() async {
  if (_featureDependenciesRegistered) return;
  _featureDependenciesRegistered = true;

  // ── Parsing Rules ──
  getIt.registerLazySingleton<ParsingIsolateService>(() => ParsingIsolateService());
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

  // ── Message Templates ──
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

  // ── Evaluate Rules (shared between SMS & Email) ──
  getIt.registerLazySingleton(
    () => EvaluateRulesUseCase(
      getIt<ParsingRulesRepository>(),
      getIt<MessageTemplateRepository>(),
    ),
  );

  // ── SMS Scanner ──
  getIt.registerLazySingleton<SmsLocalDatasource>(
    () => SmsLocalDatasourceImpl(),
  );
  getIt.registerLazySingleton(
    () => ScanSmsUseCase(
      smsDatasource: getIt<SmsLocalDatasource>(),
      evaluateRules: getIt<EvaluateRulesUseCase>(),
    ),
  );
  getIt.registerFactory<SmsScannerBloc>(
    () => SmsScannerBloc(
      scanSmsUseCase: getIt<ScanSmsUseCase>(),
      expenseRepository: getIt<ExpenseRepository>(),
    ),
  );

  // ── Reports ──
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(appDatabase: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton(
    () => GetSpendingTrend(repository: getIt<ReportsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetCategoryBreakdown(repository: getIt<ReportsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetSpendingInsights(repository: getIt<ReportsRepository>()),
  );
  getIt.registerFactory<ReportsBloc>(
    () => ReportsBloc(
      getSpendingTrend: getIt<GetSpendingTrend>(),
      getCategoryBreakdown: getIt<GetCategoryBreakdown>(),
      getSpendingInsights: getIt<GetSpendingInsights>(),
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      granularity: Granularity.daily,
    ),
  );

  // ── Budgets ──
  getIt.registerLazySingleton<BudgetDao>(() => BudgetDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<BudgetLocalDatasource>(
    () => BudgetLocalDatasourceImpl(budgetDao: getIt<BudgetDao>()),
  );
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDatasource: getIt<BudgetLocalDatasource>()),
  );
  getIt.registerLazySingleton(
    () => GetBudgets(repository: getIt<BudgetRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateBudget(repository: getIt<BudgetRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateBudget(repository: getIt<BudgetRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteBudget(repository: getIt<BudgetRepository>()),
  );
  getIt.registerFactory<BudgetBloc>(
    () => BudgetBloc(
      getBudgets: getIt<GetBudgets>(),
      createBudget: getIt<CreateBudget>(),
      updateBudget: getIt<UpdateBudget>(),
      deleteBudget: getIt<DeleteBudget>(),
    ),
  );
}

/// Backwards-compatible call that registers everything at once.
/// Used by integration tests or scenarios where layered init isn't needed.
Future<void> initDependencies() async {
  await initCriticalDependencies();
  await initFeatureDependencies();
}
