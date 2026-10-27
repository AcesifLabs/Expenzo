import 'package:expense_tracker/core/database/app_database.dart';

Future<void> seedLocalData(
  AppDatabase db, {
  int records = 1,
  int budgets = 1,
  int categories = 1,
  int recurring = 1,
  int templates = 1,
  int goals = 0,
}) async {
  final day = DateTime(2026, 3, 1);
  for (var i = 0; i < goals; i++) {
    await db
        .into(db.goals)
        .insert(
          GoalsCompanion.insert(id: 'g$i', name: 'Goal $i', targetAmount: 1000),
        );
  }
  await db
      .into(db.users)
      .insert(UsersCompanion.insert(uid: 'u1', email: 'a@b.c'));
  await db
      .into(db.syncQueue)
      .insert(
        SyncQueueCompanion.insert(
          entityTable: 'records',
          recordId: 'r0',
          action: 'create',
          payload: '{}',
        ),
      );
  for (var i = 0; i < records; i++) {
    await db
        .into(db.records)
        .insert(
          RecordsCompanion.insert(
            id: 'r$i',
            amount: -10,
            description: 'Record $i',
            date: day,
            recordType: 'OUT',
          ),
        );
  }
  for (var i = 0; i < budgets; i++) {
    await db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            id: 'b$i',
            name: 'Budget $i',
            amount: 100,
            period: 'monthly',
            startDate: day,
          ),
        );
  }
  for (var i = 0; i < categories; i++) {
    await db
        .into(db.categories)
        .insert(CategoriesCompanion.insert(id: 'c$i', name: 'Category $i'));
  }
  for (var i = 0; i < recurring; i++) {
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: 'rt$i',
            description: 'Rent',
            amount: 500,
            frequency: 'monthly',
            startDate: day,
            nextOccurrence: day,
          ),
        );
  }
  if (templates > 0) {
    await db
        .into(db.messageSources)
        .insert(
          MessageSourcesCompanion.insert(
            id: 's0',
            contactId: 'bank',
            contactName: 'Bank',
          ),
        );
  }
  for (var i = 0; i < templates; i++) {
    await db
        .into(db.expenseTemplates)
        .insert(
          ExpenseTemplatesCompanion.insert(
            id: 't$i',
            sourceId: 's0',
            sampleMessage: 'Paid 10',
            triggerWord: 'Paid',
            amountPattern: r'\d+',
          ),
        );
  }
}
