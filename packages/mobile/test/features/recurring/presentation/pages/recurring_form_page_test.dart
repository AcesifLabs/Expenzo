import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_form_page.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/pump_localized.dart';

class _MockRecurringBloc extends Mock implements RecurringBloc {}

class _MockCategoryBloc extends Mock implements CategoryBloc {}

class _FakeCategoryEvent extends Fake implements CategoryEvent {}

class _FakeRecurringEvent extends Fake implements RecurringEvent {}

void main() {
  late _MockRecurringBloc recurringBloc;
  late _MockCategoryBloc categoryBloc;

  setUpAll(() {
    registerFallbackValue(_FakeCategoryEvent());
    registerFallbackValue(_FakeRecurringEvent());
  });

  setUp(() {
    recurringBloc = _MockRecurringBloc();
    categoryBloc = _MockCategoryBloc();
    when(() => recurringBloc.state).thenReturn(const RecurringInitial());
    when(() => recurringBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => recurringBloc.close()).thenAnswer((_) async {});
    when(() => categoryBloc.state).thenReturn(const CategoryInitial());
    when(() => categoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => categoryBloc.close()).thenAnswer((_) async {});
  });

  Future<void> pumpForm(WidgetTester tester, RecurringFormPage page) {
    return pumpLocalized(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<RecurringBloc>.value(value: recurringBloc),
          BlocProvider<CategoryBloc>.value(value: categoryBloc),
        ],
        child: page,
      ),
    );
  }

  testWidgets('a new item preselects the default frequency', (tester) async {
    await pumpForm(
      tester,
      const RecurringFormPage(defaultFrequency: RecurringFrequency.weekly),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsNothing);
  });

  testWidgets('the per-item switch reads "Include in auto-create"', (
    tester,
  ) async {
    await pumpForm(tester, const RecurringFormPage());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Include in auto-create'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Include in auto-create'), findsOneWidget);
  });

  testWidgets('a new monthly item repeats on the start date\'s day', (
    tester,
  ) async {
    await pumpForm(
      tester,
      const RecurringFormPage(defaultFrequency: RecurringFrequency.monthly),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '1200');
    await tester.enterText(fields.at(1), 'Rent');
    // Typing leaves the keyboard's focus in the form; drop it first.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final add = find.widgetWithText(ElevatedButton, 'Add');
    await tester.scrollUntilVisible(
      add,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pump();

    final event =
        verify(() => recurringBloc.add(captureAny())).captured.single
            as CreateRecurring;
    expect(event.recurring.dayOfMonth, event.recurring.startDate.day);
  });
}
