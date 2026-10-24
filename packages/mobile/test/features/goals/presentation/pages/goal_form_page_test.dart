import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/presentation/goals_presentation.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/pump_localized.dart';

class _MockGoalFormBloc extends Mock implements GoalFormBloc {}

void main() {
  late _MockGoalFormBloc bloc;
  final goal = Goal(
    id: 'g-1',
    name: 'Laptop',
    targetAmount: 1999,
    savedAmount: 250,
    targetDate: DateTime(2027, 1, 24),
  );

  setUpAll(() => registerFallbackValue(const GoalFormDeleted()));

  Future<void> pumpForm(
    WidgetTester tester,
    GoalFormState state, {
    String? goalId,
  }) async {
    bloc = mockBloc<_MockGoalFormBloc, GoalFormState>(
      _MockGoalFormBloc(),
      state,
    );
    // The page fills its fields when the bloc reports ready.
    when(() => bloc.stream).thenAnswer((_) => Stream.value(state));
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(
      tester,
      BlocProvider<GoalFormBloc>.value(
        value: bloc,
        child: GoalFormPage(goalId: goalId),
      ),
    );
    await tester.pumpAndSettle();
  }

  GoalFormState ready(Goal? goal) =>
      GoalFormState(goal: goal, status: GoalFormStatus.ready);

  testWidgets('the fields show the goal', (tester) async {
    await pumpForm(tester, ready(goal), goalId: 'g-1');

    expect(find.widgetWithText(TextFormField, 'Laptop'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '1999'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '250'), findsOneWidget);
  });

  testWidgets('saving a new name sends it', (tester) async {
    await pumpForm(tester, ready(goal), goalId: 'g-1');

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Laptop'),
      'Phone',
    );
    await tester.tap(find.text(t.common.save));
    await tester.pump();

    final saved = verify(
      () => bloc.add(captureAny()),
    ).captured.whereType<GoalFormSaved>().single;
    expect(saved.goal.name, 'Phone');
    expect(saved.goal.id, 'g-1');
  });

  testWidgets('a blank name is refused', (tester) async {
    await pumpForm(tester, ready(goal), goalId: 'g-1');

    await tester.enterText(find.widgetWithText(TextFormField, 'Laptop'), '  ');
    await tester.tap(find.text(t.common.save));
    await tester.pump();

    expect(find.text(t.goals.errors.nameRequired), findsOneWidget);
    verifyNever(() => bloc.add(any(that: isA<GoalFormSaved>())));
  });

  testWidgets('cancelling the date picker keeps the date', (tester) async {
    await pumpForm(tester, ready(goal), goalId: 'g-1');
    final shown = find.textContaining('2027');
    expect(shown, findsOneWidget);

    await tester.tap(find.text(t.goals.form.targetDate));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();

    expect(find.textContaining('2027'), findsOneWidget);
  });

  testWidgets('delete asks first; Cancel sends nothing', (tester) async {
    await pumpForm(tester, ready(goal), goalId: 'g-1');

    await tester.tap(find.byTooltip(t.common.delete));
    await tester.pumpAndSettle();
    expect(find.text(t.goals.form.deleteTitle), findsOneWidget);
    await tester.tap(find.text(t.common.cancel));
    await tester.pumpAndSettle();

    verifyNever(() => bloc.add(const GoalFormDeleted()));
  });

  testWidgets(
    'create mode: new title, no saved field or delete, Save creates',
    (tester) async {
      await pumpForm(tester, ready(null));

      expect(find.text(t.goals.form.createTitle), findsOneWidget);
      expect(find.text(t.goals.form.saved), findsNothing);
      expect(find.byTooltip(t.common.delete), findsNothing);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Trip');
      await tester.enterText(fields.at(1), '500');
      await tester.tap(find.text(t.common.save));
      await tester.pump();

      final created = verify(
        () => bloc.add(captureAny()),
      ).captured.whereType<GoalFormCreated>().single;
      expect(created.goal.name, 'Trip');
      expect(created.goal.targetAmount, 500);
      expect(created.goal.savedAmount, 0);
    },
  );
}
