import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/presentation/goals_presentation.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/dashboard_goal_card.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/pump_localized.dart';

void main() {
  late MockGoalBloc bloc;

  setUp(() {
    di.getIt.registerSingleton<Future<void>>(
      Future<void>.value(),
      instanceName: 'featureReady',
    );
  });

  tearDown(() => di.getIt.reset());

  Future<void> pumpCard(WidgetTester tester, GoalState state) async {
    bloc = mockBloc<MockGoalBloc, GoalState>(MockGoalBloc(), state);
    di.getIt.registerFactory<GoalBloc>(() => bloc);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: SingleChildScrollView(child: DashboardGoalCard()),
          ),
          routes: [
            GoRoute(
              path: 'goals/new',
              builder: (_, _) => const Text('new-goal'),
            ),
            GoRoute(
              path: 'goals/:id/edit',
              builder: (_, _) => const Text('edit-goal'),
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

  GoalState ready(Goal? goal) =>
      GoalState(goal: goal, status: GoalStatus.ready);

  testWidgets('no goal shows the set-a-goal prompt, which opens the form', (
    tester,
  ) async {
    await pumpCard(tester, ready(null));

    expect(find.text(t.goals.card.setGoal), findsOneWidget);
    await tester.tap(find.text(t.goals.card.setGoal));
    await tester.pumpAndSettle();

    expect(find.text('new-goal'), findsOneWidget);
  });

  testWidgets('a half-saved goal shows its name, progress and Add to goal', (
    tester,
  ) async {
    await pumpCard(
      tester,
      ready(
        const Goal(
          id: 'g-1',
          name: 'Laptop',
          targetAmount: 2000,
          savedAmount: 1000,
        ),
      ),
    );

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(t.goals.card.addToGoal), findsOneWidget);
  });

  testWidgets('a reached goal says so and hides Add to goal', (tester) async {
    await pumpCard(
      tester,
      ready(
        const Goal(
          id: 'g-1',
          name: 'Laptop',
          targetAmount: 2000,
          savedAmount: 2000,
        ),
      ),
    );

    expect(find.text(t.goals.card.reached), findsOneWidget);
    expect(find.text(t.goals.card.addToGoal), findsNothing);
  });

  testWidgets('Add to goal with 100 sends the contribution', (tester) async {
    await pumpCard(
      tester,
      ready(
        const Goal(
          id: 'g-1',
          name: 'Laptop',
          targetAmount: 2000,
          savedAmount: 500,
        ),
      ),
    );

    await tester.tap(find.text(t.goals.card.addToGoal));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '100');
    await tester.tap(find.text(t.common.add));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const GoalContributionSubmitted(100))).called(1);
  });
}
