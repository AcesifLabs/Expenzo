import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/app_database.dart';

Future<void> seedDemoSettings({required String theme}) async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now().toUtc().toIso8601String();
  await prefs.setString(
    'user_settings',
    jsonEncode({
      'currencyCode': 'USD',
      'emailFetchLimit': 100,
      'notificationsEnabled': false,
      'theme': theme,
      'languageCode': 'en',
      'onboardingCompleted': true,
      'createdAt': now,
      'updatedAt': now,
    }),
  );
}

Future<void> seedDemoData(AppDatabase db) async {
  final now = DateTime.now();
  DateTime day(int d) => DateTime(now.year, now.month, min(d, now.day), 12);

  await db.delete(db.records).go();
  await db.delete(db.budgets).go();
  await db.delete(db.goals).go();

  final monthStart = DateTime(now.year, now.month);
  for (final (id, name, amount) in [
    ('demo_groceries', 'Groceries', 400.0),
    ('demo_going_out', 'Going out', 150.0),
  ]) {
    await db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            id: id,
            name: name,
            amount: amount,
            period: 'monthly',
            startDate: monthStart,
          ),
        );
  }

  final records = [
    ('Electricity bill', 72.00, 'default_out_bills', null, 3),
    ('Home internet', 48.00, 'default_out_bills', null, 5),
    ('Supermarket', 64.30, 'default_out_food', 'demo_groceries', 8),
    ('Bakery', 18.70, 'default_out_food', 'demo_groceries', 12),
    ('Lunch with team', 23.00, 'default_out_food', null, 15),
    ('Uber to office', 18.50, 'default_out_transport', null, 17),
    ('Metro card top-up', 23.50, 'default_out_transport', null, 19),
    ('Household supplies', 70.00, 'default_out_shopping', 'demo_groceries', 21),
    (
      'Cinema tickets',
      33.00,
      'default_out_entertainment',
      'demo_going_out',
      24,
    ),
    ('Streaming plan', 12.69, 'default_out_entertainment', null, 26),
  ];
  for (final (i, (description, amount, category, budget, d))
      in records.indexed) {
    await db
        .into(db.records)
        .insert(
          RecordsCompanion.insert(
            id: 'demo_record_$i',
            amount: -amount,
            description: description,
            date: day(d),
            categoryId: Value(category),
            budgetId: Value(budget),
            recordType: 'OUT',
          ),
        );
  }

  await db
      .into(db.goals)
      .insert(
        GoalsCompanion.insert(
          id: 'demo_goal_laptop',
          name: 'New laptop',
          targetAmount: 1999,
          savedAmount: const Value(250),
          monthlyContribution: const Value(150),
        ),
      );
}
