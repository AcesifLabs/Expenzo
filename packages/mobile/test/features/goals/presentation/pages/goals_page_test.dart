import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/presentation/goals_presentation.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/pump_localized.dart';

void main() {
  late MockGoalBloc bloc;

  const laptop = Goal(
    id: 'g-1',
    name: 'Laptop',
    targetAmount: 2000,
    savedAmount: 500,
  );
  const trip = Goal(
    id: 'g-0',
    name: 'Trip',
    targetAmount: 300,
    savedAmount: 300,
  );

  tearDown(() => di.getIt.reset());

  Future<void> pumpPage(WidgetTester tester, GoalState state) async {
    bloc = mockBloc<MockGoalBloc, GoalState>(MockGoalBloc(), state);
    di.getIt.registerFactory<GoalBloc>(() => bloc);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const GoalsPage(),
          routes: [
            GoRoute(
              path: 'goals/new',
              builder: (_, _) => const Text('new-goal'),
            ),
            GoRoute(
              path: 'goals/:id/edit',
              builder: (_, state) => Text('edit-${state.pathParameters['id']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      translated(MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  GoalState ready(List<Goal> goals) =>
      GoalState(goals: goals, status: GoalStatus.ready);

  testWidgets('lists every goal in the order given', (tester) async {
    await pumpPage(tester, ready([laptop, trip]));

    final laptopTop = tester.getTopLeft(find.text('Laptop')).dy;
    final tripTop = tester.getTopLeft(find.text('Trip')).dy;

    expect(laptopTop, lessThan(tripTop));
  });

  testWidgets('a reached goal says so and has no Add to goal', (tester) async {
    await pumpPage(tester, ready([laptop, trip]));

    expect(find.text(t.goals.card.reached), findsOneWidget);
    expect(find.text(t.goals.card.addToGoal), findsOneWidget);
  });

  testWidgets('Add to goal with 100 sends a contribution for that goal', (
    tester,
  ) async {
    await pumpPage(tester, ready([laptop, trip]));

    await tester.tap(find.text(t.goals.card.addToGoal));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '100');
    await tester.tap(find.text(t.common.add));
    await tester.pumpAndSettle();

    verify(
      () =>
          bloc.add(const GoalContributionSubmitted(goalId: 'g-1', amount: 100)),
    ).called(1);
  });

  testWidgets('tapping a goal opens its edit form', (tester) async {
    await pumpPage(tester, ready([laptop]));

    await tester.tap(find.text('Laptop'));
    await tester.pumpAndSettle();

    expect(find.text('edit-g-1'), findsOneWidget);
  });

  testWidgets('no goals shows the empty state, whose button opens the form', (
    tester,
  ) async {
    await pumpPage(tester, ready([]));

    expect(find.text(t.goals.list.empty), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, t.goals.card.newGoal));
    await tester.pumpAndSettle();

    expect(find.text('new-goal'), findsOneWidget);
  });
}
