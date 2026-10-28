import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
            GoRoute(path: 'goals', builder: (_, _) => const Text('goals')),
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
      GoalState(goals: [?goal], status: GoalStatus.ready);

  testWidgets('no goal shows the set-a-goal prompt, which opens the form', (
    tester,
  ) async {
    await pumpCard(tester, ready(null));

    expect(find.text(t.goals.card.setGoal), findsOneWidget);
    await tester.tap(find.text(t.goals.card.setGoal));
    await tester.pumpAndSettle();

    expect(find.text('new-goal'), findsOneWidget);
  });

  const halfSaved = Goal(
    id: 'g-1',
    name: 'Laptop',
    targetAmount: 2000,
    savedAmount: 1000,
  );

  testWidgets('a half-saved goal shows its name, progress and New goal', (
    tester,
  ) async {
    await pumpCard(tester, ready(halfSaved));

    expect(find.text(t.goals.card.section), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(t.goals.card.newGoal), findsOneWidget);
    expect(find.text(t.goals.card.addToGoal), findsNothing);
  });

  testWidgets('See all opens the Goals page', (tester) async {
    await pumpCard(tester, ready(halfSaved));

    await tester.tap(find.text(t.dashboard.sections.seeAll));
    await tester.pumpAndSettle();

    expect(find.text('goals'), findsOneWidget);
  });

  testWidgets('New goal opens the goal form', (tester) async {
    await pumpCard(tester, ready(halfSaved));

    await tester.tap(find.text(t.goals.card.newGoal));
    await tester.pumpAndSettle();

    expect(find.text('new-goal'), findsOneWidget);
  });

  testWidgets('a reached goal says so', (tester) async {
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
  });
}
