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
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';

import '../../../../support/factories/record_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockGetRecords extends Mock implements GetRecords {}

class _MockAddRecord extends Mock implements AddRecord {}

class _MockUpdateRecord extends Mock implements UpdateRecord {}

class _MockRecordRepository extends Mock implements RecordRepository {}

class _MockGetCategories extends Mock implements GetCategories {}

class _MockCreateCategory extends Mock implements CreateCategory {}

class _MockUpdateCategory extends Mock implements UpdateCategory {}

class _MockDeleteCategory extends Mock implements DeleteCategory {}

class _MockSearchCategories extends Mock implements SearchCategories {}

class _TestRecordBloc extends RecordBloc {
  _TestRecordBloc(this._records)
    : super(
        getRecords: _MockGetRecords(),
        addRecord: _MockAddRecord(),
        updateRecord: _MockUpdateRecord(),
        recordRepository: _MockRecordRepository(),
      );

  List<Record> _records;
  List<Record> _deleted = const [];
  var loadRequests = 0;

  void seed() => _emitLoaded();

  void fail() => emit(const RecordError("Couldn't load records"));

  void _emitLoaded() =>
      emit(RecordLoaded(records: _records, total: _records.length));

  @override
  void add(RecordEvent event) {
    if (event is DeleteRecordsEvent) {
      _deleted = event.records;
      _records = _records.where((r) => !_deleted.contains(r)).toList();
      _emitLoaded();

      return;
    }
    if (event is RestoreDeletedRecords) {
      _records = [..._records, ..._deleted];
      _deleted = const [];
      _emitLoaded();

      return;
    }
    if (event is LoadRecords) loadRequests++;
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
  return translated(
    MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RecordBloc>.value(value: recordBloc),
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
          ],
          child: const RecordListView(),
        ),
      ),
    ),
  );
}

Future<_TestRecordBloc> _pumpList(WidgetTester tester) async {
  final bloc = _TestRecordBloc([
    makeRecord(id: 'rec-1', description: 'Coffee'),
    makeRecord(id: 'rec-2', description: 'Lunch'),
    makeRecord(id: 'rec-3', description: 'Taxi'),
  ]);
  addTearDown(bloc.close);
  final categoryBloc = _TestCategoryBloc();
  addTearDown(categoryBloc.close);
  await tester.pumpWidget(_wrap(bloc, categoryBloc));
  bloc.seed();
  await tester.pump();

  return bloc;
}

Future<void> _longPress(WidgetTester tester, String text) async {
  await tester.longPress(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _dismissSnackBar(WidgetTester tester) async {
  await tester.drag(find.byType(SnackBar), const Offset(0, 100));
  await tester.pumpAndSettle();
}

void main() {
  group('RecordListView selection', () {
    testWidgets('swiping a card no longer deletes it', (tester) async {
      await _pumpList(tester);

      await tester.drag(find.text('Coffee'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('long-press selects, tap toggles, header shows the count', (
      tester,
    ) async {
      await _pumpList(tester);

      await _longPress(tester, 'Coffee');
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Activity'), findsNothing);
      expect(find.text('Filter'), findsNothing);

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear selection'));
      await tester.pumpAndSettle();
      expect(find.text('Activity'), findsOneWidget);
    });

    testWidgets('select all, delete, then Undo restores the records', (
      tester,
    ) async {
      await _pumpList(tester);

      await _longPress(tester, 'Coffee');
      await tester.tap(find.byTooltip('Select all'));
      await tester.pumpAndSettle();
      expect(find.text('3 selected'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Coffee'), findsNothing);
      expect(find.text('Taxi'), findsNothing);
      expect(find.text('3 records deleted'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Taxi'), findsOneWidget);
    });

    testWidgets('system back clears the selection first', (tester) async {
      await _pumpList(tester);

      await _longPress(tester, 'Coffee');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsNothing);
      expect(find.text('Activity'), findsOneWidget);
    });

    testWidgets('deleting one selected record says 1 record deleted', (
      tester,
    ) async {
      await _pumpList(tester);

      await _longPress(tester, 'Lunch');
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Lunch'), findsNothing);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('1 record deleted'), findsOneWidget);

      await _dismissSnackBar(tester);
    });
  });

  testWidgets('a failed load offers Try again, which reloads', (tester) async {
    final bloc = _TestRecordBloc(const []);
    addTearDown(bloc.close);
    final categoryBloc = _TestCategoryBloc();
    addTearDown(categoryBloc.close);
    await tester.pumpWidget(_wrap(bloc, categoryBloc));
    final loadsOnOpen = bloc.loadRequests;

    bloc.fail();
    await tester.pump();
    await tester.tap(find.text('Try again'));

    expect(find.text("Couldn't load records"), findsOneWidget);
    expect(bloc.loadRequests, loadsOnOpen + 1);
  });
}
