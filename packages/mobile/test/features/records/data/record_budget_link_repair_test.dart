import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/features/records/data/services/record_budget_link_repair.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRemote extends Mock implements RecordRemoteDatasource {}

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
    when(() => remote.fillMissingBudgetLinks(any())).thenAnswer((_) async {});
  });

  tearDown(() => db.close());

  Future<void> insertRecord(String id, [String? budgetId]) => db
      .into(db.records)
      .insert(
        RecordsCompanion.insert(
          id: id,
          amount: 10,
          description: 'Record $id',
          date: DateTime.utc(2026, 1, 1),
          budgetId: Value(budgetId),
          recordType: 'OUT',
        ),
      );

  RecordBudgetLinkRepair repair() => RecordBudgetLinkRepair(
    recordDao: RecordDao(db),
    remote: remote,
    prefs: prefs,
    currentUserId: () => userId,
  );

  List<List<RecordBudgetLink>> sentBatches() => verify(
    () => remote.fillMissingBudgetLinks(captureAny()),
  ).captured.cast<List<RecordBudgetLink>>();

  test('sends only linked records, then stops being pending', () async {
    await insertRecord('r1', 'bud-1');
    await insertRecord('r2');

    await repair().runOnce();

    expect(sentBatches(), [
      [(id: 'r1', budgetId: 'bud-1')],
    ]);
    expect(repair().isPending, isFalse);
  });

  test('sends large sets in batches the server accepts', () async {
    for (var i = 0; i < 450; i++) {
      await insertRecord('r$i', 'bud-1');
    }

    await repair().runOnce();

    expect(sentBatches().map((b) => b.length), [200, 200, 50]);
  });

  test('runs only once', () async {
    await insertRecord('r1', 'bud-1');

    await repair().runOnce();
    await repair().runOnce();

    verify(() => remote.fillMissingBudgetLinks(any())).called(1);
  });

  test('stays pending when the server rejects a batch', () async {
    await insertRecord('r1', 'bud-1');
    when(
      () => remote.fillMissingBudgetLinks(any()),
    ).thenThrow(ServerException(message: 'rejected'));

    await expectLater(repair().runOnce(), throwsA(isA<ServerException>()));

    expect(repair().isPending, isTrue);
  });

  test('finishes without a request when no record has a link', () async {
    await insertRecord('r1');

    await repair().runOnce();

    verifyNever(() => remote.fillMissingBudgetLinks(any()));
    expect(repair().isPending, isFalse);
  });

  test('does nothing while signed out and stays pending', () async {
    await insertRecord('r1', 'bud-1');
    userId = null;

    await repair().runOnce();

    verifyNever(() => remote.fillMissingBudgetLinks(any()));
    expect(repair().isPending, isTrue);
  });

  test('tracks each account separately', () async {
    await insertRecord('r1', 'bud-1');
    await repair().runOnce();

    userId = 'user-b';

    expect(repair().isPending, isTrue);
    await repair().runOnce();
    verify(() => remote.fillMissingBudgetLinks(any())).called(2);
  });

  test('calls made during a run share it', () async {
    await insertRecord('r1', 'bud-1');
    final shared = repair();

    await Future.wait([shared.runOnce(), shared.runOnce()]);

    verify(() => remote.fillMissingBudgetLinks(any())).called(1);
  });
}
