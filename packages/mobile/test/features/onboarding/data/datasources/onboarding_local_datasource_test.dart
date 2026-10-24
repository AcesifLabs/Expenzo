import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_local_datasource.dart';

void main() {
  late AppDatabase db;
  late OnboardingLocalDatasource local;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await DatabaseSeeder.seedInitialCategories(db);
    local = OnboardingLocalDatasource(db: db);
  });

  tearDown(() => db.close());

  test('seeded categories alone are not user data', () async {
    expect(await local.hasUserData(), isFalse);
  });

  test('one transaction is user data', () async {
    await db
        .into(db.records)
        .insert(
          RecordsCompanion.insert(
            id: 'r-1',
            amount: -10,
            description: 'Tea',
            date: DateTime(2026, 10, 1),
            recordType: 'OUT',
          ),
        );

    expect(await local.hasUserData(), isTrue);
  });

  test('a recurring item alone is user data', () async {
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: 'rec-1',
            description: 'Rent',
            amount: 1200,
            frequency: 'monthly',
            startDate: DateTime(2026, 10, 1),
            nextOccurrence: DateTime(2026, 11, 1),
          ),
        );

    expect(await local.hasUserData(), isTrue);
  });
}
