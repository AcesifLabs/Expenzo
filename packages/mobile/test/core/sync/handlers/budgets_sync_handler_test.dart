import 'package:drift/native.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/sync/handlers/budgets_sync_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final handler = BudgetsSyncHandler();
  final now = DateTime.utc(2026, 10, 11);

  Budget budget({String name = 'Groceries'}) => Budget(
    id: 'bud-1',
    name: name,
    amount: 400,
    period: 'monthly',
    startDate: now,
    rolloverEnabled: false,
    rolloverAmount: 0,
    isEnabled: true,
    createdAt: now,
    updatedAt: now,
  );

  BudgetsCompanion pulled(Map<String, dynamic> payload) =>
      handler.fromSyncPayload('bud-1', payload) as BudgetsCompanion;

  group('BudgetsSyncHandler', () {
    group('name payload', () {
      test('sends the name in the push payload', () {
        expect(handler.toSyncPayload(budget())['name'], 'Groceries');
      });

      test('keeps the name through a push and pull round trip', () {
        expect(pulled(handler.toSyncPayload(budget())).name.value, 'Groceries');
      });

      for (final (label, value) in [
        ('missing', null),
        ('empty', ''),
        ('whitespace only', '   '),
      ]) {
        test('uses the default name when the pulled name is $label', () {
          final payload = handler.toSyncPayload(budget())..['name'] = value;

          expect(pulled(payload).name.value, AppConstants.defaultBudgetName);
        });
      }
    });

    group('keepLocalValues while the name repair is pending', () {
      late AppDatabase db;
      final pending = BudgetsSyncHandler(keepLocalNames: () => true);

      setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
      tearDown(() => db.close());

      Future<String> resolve({
        required String pulledName,
        BudgetsSyncHandler? using,
      }) async {
        final incoming = pulled(
          handler.toSyncPayload(budget(name: pulledName)),
        );
        final merged =
            await (using ?? pending).keepLocalValues(db, 'bud-1', incoming)
                as BudgetsCompanion;

        return merged.name.value;
      }

      test('keeps the local name when the server sends the default', () async {
        await db.into(db.budgets).insert(budget());

        expect(
          await resolve(pulledName: AppConstants.defaultBudgetName),
          'Groceries',
        );
      });

      test('takes a real name from the server', () async {
        await db.into(db.budgets).insert(budget());

        expect(await resolve(pulledName: 'Food'), 'Food');
      });

      test('uses the default when there is no local budget', () async {
        expect(
          await resolve(pulledName: AppConstants.defaultBudgetName),
          AppConstants.defaultBudgetName,
        );
      });

      test('takes the default once the repair is done', () async {
        await db.into(db.budgets).insert(budget());

        expect(
          await resolve(
            pulledName: AppConstants.defaultBudgetName,
            using: handler,
          ),
          AppConstants.defaultBudgetName,
        );
      });

      test('uses the default when the local name is empty', () async {
        await db.into(db.budgets).insert(budget(name: ''));

        expect(
          await resolve(pulledName: AppConstants.defaultBudgetName),
          AppConstants.defaultBudgetName,
        );
      });
    });
  });

  group('beforeApplyingPull', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('loads local names once and uses them for the pull', () async {
      final pending = BudgetsSyncHandler(keepLocalNames: () => true);
      await db.into(db.budgets).insert(budget());
      await pending.beforeApplyingPull(db, ['bud-1']);
      // The row is gone, so a fresh lookup would find nothing.
      await db.delete(db.budgets).go();

      final merged =
          await pending.keepLocalValues(
                db,
                'bud-1',
                pulled(
                  handler.toSyncPayload(
                    budget(name: AppConstants.defaultBudgetName),
                  ),
                ),
              )
              as BudgetsCompanion;
      await pending.afterApplyingPull();

      expect(merged.name.value, 'Groceries');
    });

    test('loads nothing once the repair is done', () async {
      await db.into(db.budgets).insert(budget());
      await handler.beforeApplyingPull(db, ['bud-1']);

      final merged =
          await handler.keepLocalValues(
                db,
                'bud-1',
                pulled(
                  handler.toSyncPayload(
                    budget(name: AppConstants.defaultBudgetName),
                  ),
                ),
              )
              as BudgetsCompanion;

      expect(merged.name.value, AppConstants.defaultBudgetName);
    });
  });
}
