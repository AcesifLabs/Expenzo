import 'sync_table_registry.dart';
import 'handlers/records_sync_handler.dart';
import 'handlers/categories_sync_handler.dart';
import 'handlers/budgets_sync_handler.dart';
import 'handlers/goals_sync_handler.dart';
import 'handlers/message_sources_sync_handler.dart';
import 'handlers/expense_templates_sync_handler.dart';
import 'handlers/parsing_rules_sync_handler.dart';
import 'handlers/recurring_transactions_sync_handler.dart';
import 'handlers/pending_recurring_sync_handler.dart';

// Optional: tests build the registry without the repair checks.
// ignore: unnecessary-nullable
/// [keepLocalBudgetNames]: see [BudgetsSyncHandler.keepLocalNames].
/// [keepLocalRecordBudgetLinks]: see [RecordsSyncHandler.keepLocalBudgetLinks].
SyncTableRegistry createDefaultSyncRegistry({
  bool Function()? keepLocalBudgetNames,
  bool Function()? keepLocalRecordBudgetLinks,
}) {
  final registry = SyncTableRegistry();
  registry.register(
    RecordsSyncHandler(keepLocalBudgetLinks: keepLocalRecordBudgetLinks),
  );
  registry.register(CategoriesSyncHandler());
  registry.register(BudgetsSyncHandler(keepLocalNames: keepLocalBudgetNames));
  registry.register(GoalsSyncHandler());
  registry.register(MessageSourcesSyncHandler());
  registry.register(ExpenseTemplatesSyncHandler());
  registry.register(ParsingRulesSyncHandler());
  registry.register(RecurringTransactionsSyncHandler());
  registry.register(PendingRecurringSyncHandler());

  return registry;
}
