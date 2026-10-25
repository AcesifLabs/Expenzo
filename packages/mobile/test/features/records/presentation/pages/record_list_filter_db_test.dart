import 'package:drift/native.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/create_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/delete_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/categories/domain/usecases/search_categories.dart';
import 'package:expense_tracker/features/categories/domain/usecases/update_category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/record_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _MockGetCategories extends Mock implements GetCategories {}

class _MockCreateCategory extends Mock implements CreateCategory {}

class _MockUpdateCategory extends Mock implements UpdateCategory {}

class _MockDeleteCategory extends Mock implements DeleteCategory {}

class _MockSearchCategories extends Mock implements SearchCategories {}

/// Categories play no part here; this one ignores the load the page fires.
class _IdleCategoryBloc extends CategoryBloc {
  _IdleCategoryBloc()
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

/// The records list on a real database: DAO, repository and bloc, with no
/// server at all, as for a guest.
void main() {
  late db.AppDatabase database;
  late RecordRepositoryImpl repository;
  late RecordBloc bloc;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = RecordRepositoryImpl(
      localDatasource: RecordLocalDatasourceImpl(
        recordDao: RecordDao(database),
      ),
    );
    bloc = RecordBloc(
      getRecords: GetRecords(repository),
      addRecord: AddRecord(repository, _MockCategoryRepository()),
      updateRecord: UpdateRecord(repository),
      deleteRecord: DeleteRecord(repository),
      recordRepository: repository,
    );
  });

  Future<void> insert(
    WidgetTester tester,
    String id, {
    RecordType type = RecordType.expense,
    int minute = 0,
  }) => tester.runAsync(
    () => repository.addRecord(
      makeRecord(
        id: id,
        description: id,
        recordType: type,
        date: DateTime(2026, 10, 1, 10, minute),
      ),
    ),
  );

  /// Lets the database send its update, then draws it.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpWidget(
      translated(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<RecordBloc>.value(value: bloc),
                BlocProvider<CategoryBloc>.value(value: _IdleCategoryBloc()),
              ],
              child: const RecordListView(),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> tearDownAll(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await bloc.close();
      await database.close();
    });
  }

  testWidgets('a filtered list shows new matching records only', (
    tester,
  ) async {
    await insert(tester, 'Old income', type: RecordType.income);
    await pumpList(tester);

    bloc.add(ApplyFilters(recordType: RecordType.expense.dbValue));
    await settle(tester);
    await insert(tester, 'Groceries', minute: 1);
    await insert(tester, 'Salary', type: RecordType.income, minute: 2);
    await settle(tester);

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Old income'), findsNothing);
    await tearDownAll(tester);
  });

  testWidgets('an update after load more keeps every loaded row', (
    tester,
  ) async {
    for (var i = 0; i < 60; i++) {
      await insert(tester, 'r$i', minute: i % 60);
    }
    await pumpList(tester);
    bloc.add(ApplyFilters(recordType: RecordType.expense.dbValue));
    await settle(tester);
    bloc.add(const LoadMoreRecords());
    await settle(tester);
    expect((bloc.state as RecordLoaded).records, hasLength(60));

    await insert(tester, 'one more', minute: 59);
    await settle(tester);

    expect((bloc.state as RecordLoaded).records, hasLength(61));
    await tearDownAll(tester);
  });
}
