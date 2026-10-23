import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_list_page.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_category_record_counts.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/pump_localized.dart';

class _MockCategoryBloc extends Mock implements CategoryBloc {}

class _MockGetCounts extends Mock implements GetCategoryRecordCounts {}

class _FakeCategoryEvent extends Fake implements CategoryEvent {}

Category _category(String id, String name, RecordType type) => Category(
  id: id,
  name: name,
  emoji: 'tag',
  color: '#FFCDD2',
  isDefault: id.startsWith('default_'),
  type: type,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _MockCategoryBloc bloc;
  late _MockGetCounts getCounts;
  late StreamController<CategoryState> states;

  final food = _category(
    'default_out_food',
    'Food & Dining',
    RecordType.expense,
  );
  final rent = _category('custom_rent', 'Rent', RecordType.expense);
  final salary = _category('default_in_salary', 'Salary', RecordType.income);

  setUpAll(() {
    registerFallbackValue(_FakeCategoryEvent());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    bloc = _MockCategoryBloc();
    getCounts = _MockGetCounts();
    states = StreamController<CategoryState>.broadcast();
    when(() => bloc.stream).thenAnswer((_) => states.stream);
    when(() => bloc.close()).thenAnswer((_) async {});
    when(
      () => getCounts(any()),
    ).thenAnswer((_) async => const Right({'default_out_food': 42}));
  });

  tearDown(() => states.close());

  /// Moves the mocked bloc to [state] and lets the page react.
  Future<void> emit(WidgetTester tester, CategoryState state) async {
    when(() => bloc.state).thenReturn(state);
    states.add(state);
    await tester.pump();
  }

  Future<void> pumpPage(WidgetTester tester, CategoryState state) async {
    when(() => bloc.state).thenReturn(state);
    await pumpLocalized(
      tester,
      CategoryListPage(getCounts: getCounts),
      wrap: (app) => BlocProvider<CategoryBloc>.value(value: bloc, child: app),
    );
    await tester.pump();
  }

  testWidgets('shows expense and income sections with counts', (tester) async {
    await pumpPage(tester, CategoryLoaded([food, rent, salary]));

    expect(find.text('EXPENSE CATEGORIES'), findsOneWidget);
    expect(find.text('INCOME CATEGORIES'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('42 transactions'), findsOneWidget);
    expect(find.text('0 transactions'), findsNWidgets(2));
  });

  testWidgets('initState loads every category sorted by usage', (tester) async {
    await pumpPage(tester, CategoryLoaded([food]));

    verify(() => bloc.add(const LoadCategories(sortByUsage: true))).called(1);
  });

  testWidgets('failed counts show no count on any row', (tester) async {
    when(
      () => getCounts(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));

    await pumpPage(tester, CategoryLoaded([food, salary]));

    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.textContaining('transaction'), findsNothing);
  });

  testWidgets('a type with no categories hides its section', (tester) async {
    await pumpPage(tester, CategoryLoaded([food, rent]));

    expect(find.text('EXPENSE CATEGORIES'), findsOneWidget);
    expect(find.text('INCOME CATEGORIES'), findsNothing);
  });

  testWidgets('a type-filtered list left by the sheet shows a spinner', (
    tester,
  ) async {
    await pumpPage(
      tester,
      CategoryLoaded([food, rent], type: RecordType.expense),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Food & Dining'), findsNothing);
  });

  testWidgets('long-press on a default category refuses deletion', (
    tester,
  ) async {
    await pumpPage(tester, CategoryLoaded([food]));

    await tester.longPress(find.text('Food & Dining'));
    await tester.pump();

    expect(find.text(t.categories.defaultCannotDelete), findsOneWidget);
    verifyNever(() => bloc.add(any(that: isA<DeleteCategoryEvent>())));
  });

  testWidgets('a failed first load offers Try again', (tester) async {
    await pumpPage(tester, const CategoryError('x'));

    expect(find.text('x'), findsOneWidget);
    clearInteractions(bloc);
    await tester.tap(find.text('Try again'));
    await tester.pump();

    verify(() => bloc.add(const LoadCategories(sortByUsage: true))).called(1);
  });

  testWidgets('a failed save from the form keeps the list and says why', (
    tester,
  ) async {
    await pumpPage(tester, CategoryLoaded([food, rent]));
    clearInteractions(bloc);

    await emit(tester, const CategoryLoading());
    await emit(tester, const CategoryError('Something went wrong'));

    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    verify(() => bloc.add(const LoadCategories(sortByUsage: true))).called(1);
  });

  testWidgets('a second failure in a row shows the error with Try again', (
    tester,
  ) async {
    await pumpPage(tester, CategoryLoaded([food, rent]));

    await emit(tester, const CategoryError('first'));
    await emit(tester, const CategoryError('second'));

    expect(find.text('Food & Dining'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('a failed delete shows the delete message and keeps the list', (
    tester,
  ) async {
    await pumpPage(tester, CategoryLoaded([food, rent]));

    await tester.longPress(find.text('Rent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.common.delete));
    await tester.pumpAndSettle();
    verify(() => bloc.add(const DeleteCategoryEvent('custom_rent'))).called(1);

    await emit(tester, const CategoryLoading());
    await emit(tester, const CategoryError('x'));

    expect(find.text(t.categories.settings.deleteFailed), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('an unrelated load does not end a running delete', (
    tester,
  ) async {
    await pumpPage(tester, CategoryLoaded([food, rent]));

    await tester.longPress(find.text('Rent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.common.delete));
    await tester.pumpAndSettle();

    // A load that finished before the delete started.
    await emit(tester, CategoryLoaded([food, rent]));
    await emit(tester, const CategoryLoading());
    await emit(tester, const CategoryError('x'));
    await tester.pump();

    expect(find.text(t.categories.settings.deleteFailed), findsOneWidget);
  });

  testWidgets('a type-filtered list arriving later triggers a full reload', (
    tester,
  ) async {
    await pumpPage(tester, CategoryLoaded([food, salary]));
    clearInteractions(bloc);

    await emit(tester, CategoryLoaded([food], type: RecordType.expense));

    expect(find.text('Salary'), findsOneWidget);
    verify(() => bloc.add(const LoadCategories(sortByUsage: true))).called(1);
  });

  testWidgets('an older count result cannot overwrite a newer one', (
    tester,
  ) async {
    final slow = Completer<Either<Failure, Map<String, int>>>();
    var calls = 0;
    when(() => getCounts(any())).thenAnswer((_) {
      calls++;
      return calls == 1
          ? slow.future
          : Future.value(const Right({'default_out_food': 7}));
    });

    await pumpPage(tester, CategoryLoaded([food]));
    await tester.fling(find.text('Food & Dining'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(find.text('7 transactions'), findsOneWidget);

    slow.complete(const Right({'default_out_food': 1}));
    await tester.pump();

    expect(find.text('7 transactions'), findsOneWidget);
  });

  testWidgets('rows far down a long list are built only when scrolled to', (
    tester,
  ) async {
    final many = [
      for (var i = 0; i < 60; i++)
        _category('custom_$i', 'Custom $i', RecordType.expense),
    ];
    await pumpPage(tester, CategoryLoaded(many));

    expect(find.text('Custom 0'), findsOneWidget);
    expect(find.text('Custom 59', skipOffstage: false), findsNothing);

    await tester.scrollUntilVisible(find.text('Custom 59'), 300);
    expect(find.text('Custom 59'), findsOneWidget);
  });
}
