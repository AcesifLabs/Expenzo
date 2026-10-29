import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_plan_snapshot.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_changes.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_plan.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/save_budget_plan.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_plan_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_plan_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../support/connectivity_test_support.dart';
import '../../../support/factories/budget_factory.dart';
import '../../../support/pump_localized.dart';

class _MockGet extends Mock implements GetBudgetPlan {}

class _MockSave extends Mock implements SaveBudgetPlan {}

void main() {
  late _MockGet getPlan;
  late _MockSave savePlan;
  bool? popped;

  final rent = makeBudget(id: '1', name: 'Rent', amount: 1000);
  final food = makeBudget(id: '2', name: 'Food', amount: 400);

  setUpAll(() {
    registerFallbackValue(
      const SaveBudgetPlanParams(
        changes: PlanChanges.empty,
        monthlyIncome: null,
      ),
    );
  });

  setUp(() {
    popped = null;
    getPlan = _MockGet();
    savePlan = _MockSave();
    when(() => getPlan()).thenAnswer(
      (_) async => Right(
        BudgetPlanSnapshot(
          monthlyIncome: 5000,
          recurringTotal: 1000,
          budgets: [food, rent],
        ),
      ),
    );
    when(() => savePlan(any())).thenAnswer((_) async => const Right(unit));
  });

  Future<void> pumpPage(WidgetTester tester) async {
    registerTestConnectivity();
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () async => popped = await context.push<bool>('/plan'),
              child: const Text('open'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'plan',
              builder: (_, _) => BlocProvider(
                create: (_) => BudgetPlanBloc(
                  getBudgetPlan: getPlan,
                  saveBudgetPlan: savePlan,
                ),
                child: const BudgetPlanPage(),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      translated(MaterialApp.router(routerConfig: router)),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(String text) => find.widgetWithText(TextField, text);

  SaveBudgetPlanParams saved() =>
      verify(() => savePlan(captureAny())).captured.single
          as SaveBudgetPlanParams;

  testWidgets('shows income, what is left and each budget', (tester) async {
    await pumpPage(tester);

    expect(field('5000.00'), findsOneWidget);
    expect(field('Food'), findsOneWidget);
    expect(field('Rent'), findsOneWidget);
    expect(find.textContaining('2,600.00 left to assign'), findsOneWidget);
  });

  testWidgets('saving edits pops true without a dialog', (tester) async {
    await pumpPage(tester);

    await tester.enterText(field('5000.00'), '6000');
    await tester.enterText(field('400'), '500');
    await tester.pump();
    await tester.tap(find.text(t.common.save));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    final params = saved();
    expect(params.monthlyIncome, 6000);
    expect(params.changes.toUpdate.single, food.copyWith(amount: 500));
    expect(params.changes.toDelete, isEmpty);
    expect(popped, isTrue);
  });

  testWidgets('removing a budget asks first and lists it', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Remove Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.common.save));
    await tester.pumpAndSettle();

    expect(find.text(t.budgets.plan.deleteBody(names: 'Food')), findsOneWidget);

    await tester.tap(find.text(t.common.cancel));
    await tester.pumpAndSettle();
    verifyNever(() => savePlan(any()));
    expect(popped, isNull);

    await tester.tap(find.text(t.common.save));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.common.delete));
    await tester.pumpAndSettle();

    expect(saved().changes.toDelete, [food]);
    expect(popped, isTrue);
  });

  testWidgets('an invalid row blocks saving and shows the error', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(field('Food'), 'rent');
    await tester.pump();
    await tester.tap(find.text(t.common.save));
    await tester.pumpAndSettle();

    expect(find.text(t.budgets.plan.nameDuplicate), findsNWidgets(2));
    verifyNever(() => savePlan(any()));
  });

  testWidgets('after a failed save the income field shows what is stored', (
    tester,
  ) async {
    when(
      () => savePlan(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk')));
    await pumpPage(tester);

    await tester.enterText(field('5000.00'), '6000');
    await tester.pump();
    await tester.tap(find.text(t.common.save));
    await tester.pumpAndSettle();

    expect(find.text(t.budgets.plan.saveFailed), findsOneWidget);
    expect(field('5000.00'), findsOneWidget);
    expect(popped, isNull);
  });

  testWidgets('a blank income still plans against the stored one', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(field('5000.00'), '');
    await tester.pump();

    expect(find.textContaining('2,600.00 left to assign'), findsOneWidget);
  });
}
