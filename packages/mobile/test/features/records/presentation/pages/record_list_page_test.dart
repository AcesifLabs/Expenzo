import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/domain/usecases/create_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/delete_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/categories/domain/usecases/search_categories.dart';
import 'package:expense_tracker/features/categories/domain/usecases/update_category.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';

import '../../../../support/factories/record_factory.dart';

class _MockGetRecords extends Mock implements GetRecords {}

class _MockAddRecord extends Mock implements AddRecord {}

class _MockUpdateRecord extends Mock implements UpdateRecord {}

class _MockDeleteRecord extends Mock implements DeleteRecord {}

class _MockRecordRepository extends Mock implements RecordRepository {}

class _MockGetCategories extends Mock implements GetCategories {}

class _MockCreateCategory extends Mock implements CreateCategory {}

class _MockUpdateCategory extends Mock implements UpdateCategory {}

class _MockDeleteCategory extends Mock implements DeleteCategory {}

class _MockSearchCategories extends Mock implements SearchCategories {}

/// Stands in for the real bloc: swallows the loads the page fires on build,
/// and applies [DeleteRecordEvent] synchronously so the dismissed card leaves
/// the tree in the same frame (the app gets this from the Drift watch stream;
/// without it Flutter throws "A dismissed Dismissible widget is still part of
/// the tree").
class _TestRecordBloc extends RecordBloc {
  _TestRecordBloc(this._records)
    : super(
        getRecords: _MockGetRecords(),
        addRecord: _MockAddRecord(),
        updateRecord: _MockUpdateRecord(),
        deleteRecord: _MockDeleteRecord(),
        recordRepository: _MockRecordRepository(),
      );

  List<Record> _records;

  void seed() => _emitLoaded();

  void _emitLoaded() =>
      emit(RecordLoaded(records: _records, total: _records.length));

  @override
  void add(RecordEvent event) {
    if (event is DeleteRecordEvent) {
      _records = _records.where((r) => r.id != event.id).toList();
      _emitLoaded();

      return;
    }
    if (event is LoadRecords || event is LoadMoreRecords) return;
    super.add(event);
  }
}

class _TestCategoryBloc extends CategoryBloc {
  _TestCategoryBloc()
    : super(
        getCategories: _MockGetCategories(),
        createCategory: _MockCreateCategory(),
        updateCategory: _MockUpdateCategory(),
        deleteCategory: _MockDeleteCategory(),
        searchCategories: _MockSearchCategories(),
      );

  @override
  void add(CategoryEvent event) {
    if (event is LoadCategories) return;
    super.add(event);
  }
}

Widget _wrap(RecordBloc recordBloc, CategoryBloc categoryBloc) {
  // RecordListView (not RecordListPage) because the page resolves its blocs
  // from getIt. The outer Scaffold is required: showSnackBar asserts a
  // registered Scaffold, and AppScaffold is a Material, not a Scaffold.
  return MaterialApp(
    home: Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<RecordBloc>.value(value: recordBloc),
          BlocProvider<CategoryBloc>.value(value: categoryBloc),
        ],
        child: const RecordListView(),
      ),
    ),
  );
}

/// Swipes a card away and lets the dismiss animation finish, which is what
/// actually fires `onDismissed` -> `_handleDelete`.
Future<void> _swipeAway(WidgetTester tester, String id) async {
  await tester.drag(find.byKey(Key('record_$id')), const Offset(-600, 0));
  await tester.pumpAndSettle();
}

/// Dismisses the visible SnackBar the way a user does — a downward swipe
/// ([DismissDirection.down] is the SnackBar default). This is the gesture that
/// exposed the bug: dismissing the top toast revealed the next queued one.
Future<void> _dismissSnackBar(WidgetTester tester) async {
  await tester.drag(find.byType(SnackBar), const Offset(0, 100));
  await tester.pumpAndSettle();
}

void main() {
  group('RecordListView delete SnackBar', () {
    testWidgets('a burst of deletes shows one SnackBar, not a queue', (
      tester,
    ) async {
      final bloc = _TestRecordBloc([
        makeRecord(id: 'rec-1', description: 'Coffee'),
        makeRecord(id: 'rec-2', description: 'Lunch'),
      ]);
      addTearDown(bloc.close);
      final categoryBloc = _TestCategoryBloc();
      addTearDown(categoryBloc.close);

      await tester.pumpWidget(_wrap(bloc, categoryBloc));
      bloc.seed();
      await tester.pump();

      // Second delete lands while the first toast is still on screen.
      await _swipeAway(tester, 'rec-1');
      await _swipeAway(tester, 'rec-2');

      expect(find.text('Record deleted'), findsOneWidget);

      // The reported symptom: dismissing the visible toast must not reveal a
      // second one queued behind it. This toast carries an Undo action, and a
      // SnackBar with an action defaults to `persist: true` (Flutter's
      // SnackBar ctor: `persist = persist ?? action != null`), so a queued
      // toast never times out on its own — it waits for the user.
      await _dismissSnackBar(tester);

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a single delete still shows the SnackBar with Undo', (
      tester,
    ) async {
      final bloc = _TestRecordBloc([
        makeRecord(id: 'rec-1', description: 'Coffee'),
      ]);
      addTearDown(bloc.close);
      final categoryBloc = _TestCategoryBloc();
      addTearDown(categoryBloc.close);

      await tester.pumpWidget(_wrap(bloc, categoryBloc));
      bloc.seed();
      await tester.pump();

      await _swipeAway(tester, 'rec-1');

      expect(find.text('Record deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await _dismissSnackBar(tester);

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
