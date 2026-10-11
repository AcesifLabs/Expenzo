import 'package:drift/native.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:expense_tracker/features/budgets/data/services/budget_name_repair.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRemote extends Mock implements BudgetRemoteDatasource {}

void main() {
  late AppDatabase db;
  late _MockRemote remote;
  late SharedPreferences prefs;
  String? userId;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    remote = _MockRemote();
    userId = 'user-a';
    when(() => remote.fillMissingNames(any())).thenAnswer((_) async {});
  });

  tearDown(() => db.close());

  Future<void> insertBudget(String id, String name) => db
      .into(db.budgets)
      .insert(
        BudgetsCompanion.insert(
          id: id,
          name: name,
          amount: 100,
          period: 'monthly',
          startDate: DateTime.utc(2026, 1, 1),
        ),
      );

  BudgetNameRepair repair() => BudgetNameRepair(
    budgetDao: BudgetDao(db),
    remote: remote,
    prefs: prefs,
    currentUserId: () => userId,
  );

  List<List<BudgetNameEntry>> sentBatches() => verify(
    () => remote.fillMissingNames(captureAny()),
  ).captured.cast<List<BudgetNameEntry>>();

  test('sends only real names, then stops being pending', () async {
    await insertBudget('b1', 'Groceries');
    await insertBudget('b2', '');
    await insertBudget('b3', AppConstants.defaultBudgetName);

    await repair().runOnce();

    expect(sentBatches(), [
      [(id: 'b1', name: 'Groceries')],
    ]);
    expect(repair().isPending, isFalse);
  });

  test('skips names the server would reject', () async {
    await insertBudget('b1', 'Groceries');
    await insertBudget('b2', 'x' * (AppConstants.budgetNameMaxLength + 1));

    await repair().runOnce();

    expect(sentBatches().single.map((n) => n.id), ['b1']);
  });

  test('sends large sets in batches the server accepts', () async {
    for (var i = 0; i <= AppConstants.fillBudgetNamesBatchSize; i++) {
      await insertBudget('b$i', 'Budget $i');
    }

    await repair().runOnce();

    expect(sentBatches().map((b) => b.length), [
      AppConstants.fillBudgetNamesBatchSize,
      1,
    ]);
  });

  test('runs only once', () async {
    await insertBudget('b1', 'Groceries');

    await repair().runOnce();
    await repair().runOnce();

    verify(() => remote.fillMissingNames(any())).called(1);
  });

  test('stays pending when the server rejects a batch', () async {
    await insertBudget('b1', 'Groceries');
    when(
      () => remote.fillMissingNames(any()),
    ).thenThrow(ServerException(message: 'rejected'));

    await expectLater(repair().runOnce(), throwsA(isA<ServerException>()));

    expect(repair().isPending, isTrue);
  });

  test('finishes without a request when no budget has a name', () async {
    await insertBudget('b1', '');

    await repair().runOnce();

    verifyNever(() => remote.fillMissingNames(any()));
    expect(repair().isPending, isFalse);
  });

  test('does nothing while signed out and stays pending', () async {
    await insertBudget('b1', 'Groceries');
    userId = null;

    await repair().runOnce();

    verifyNever(() => remote.fillMissingNames(any()));
    expect(repair().isPending, isTrue);
  });

  test('tracks each account separately', () async {
    await insertBudget('b1', 'Groceries');
    await repair().runOnce();

    userId = 'user-b';

    expect(repair().isPending, isTrue);
    await repair().runOnce();
    verify(() => remote.fillMissingNames(any())).called(2);
  });

  test('calls made during a run share it', () async {
    await insertBudget('b1', 'Groceries');
    final shared = repair();

    await Future.wait([shared.runOnce(), shared.runOnce()]);

    verify(() => remote.fillMissingNames(any())).called(1);
  });
}
