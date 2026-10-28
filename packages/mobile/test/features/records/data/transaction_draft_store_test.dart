import 'package:clock/clock.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/records/data/services/transaction_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late TransactionDraftStore store;
  final draft = (
    type: RecordType.expense,
    amountText: '250.5',
    note: 'Lunch',
    categoryId: 'cat-food',
    budgetId: null,
    date: DateTime(2026, 10, 24),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = TransactionDraftStore(await SharedPreferences.getInstance());
  });

  test('a saved draft comes back field for field', () async {
    await store.save(draft);

    expect(store.load(), draft);
  });

  test('clear removes it', () async {
    await store.save(draft);
    await store.clear();

    expect(store.load(), isNull);
  });

  test('a draft older than a day is not restored', () async {
    await withClock(
      Clock.fixed(DateTime(2026, 10, 20)),
      () => store.save(draft),
    );

    final loaded = withClock(
      Clock.fixed(DateTime(2026, 10, 21, 1)),
      () => store.load(),
    );

    expect(loaded, isNull);
  });

  test('an unreadable draft is ignored', () async {
    SharedPreferences.setMockInitialValues({
      TransactionDraftStore.storageKey: '{not json',
    });
    store = TransactionDraftStore(await SharedPreferences.getInstance());

    expect(store.load(), isNull);
  });
}
