import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/family/domain/repositories/family_repository.dart';

import '../../../support/connectivity_test_support.dart';
import '../../../support/core_screens.dart';
import '../../../support/pump_localized.dart';

class _MockFamilyRepository extends Mock implements FamilyRepository {}

class _FakeBudgetEvent extends Fake implements BudgetEvent {}

void main() {
  late MockBudgetBloc bloc;

  setUpAll(() => registerFallbackValue(_FakeBudgetEvent()));

  setUp(() {
    final family = _MockFamilyRepository();
    when(() => family.cachedGroup).thenReturn(null);
    di.getIt.registerSingleton<FamilyRepository>(family);
    bloc = mockBloc<MockBudgetBloc, BudgetState>(
      MockBudgetBloc(),
      const BudgetLoaded([]),
    );
    when(() => bloc.add(any())).thenReturn(null);
  });

  tearDown(() => di.getIt.unregister<FamilyRepository>());

  Future<void> pumpList(WidgetTester tester, {required bool saved}) async {
    registerTestConnectivity();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<BudgetBloc>.value(
            value: bloc,
            child: const Scaffold(body: BudgetListView()),
          ),
          routes: [
            GoRoute(
              path: 'settings/budget-plan',
              builder: (context, _) => TextButton(
                onPressed: () => context.pop(saved),
                child: const Text('plan-page'),
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
    await tester.pump();
  }

  Future<void> openPlanAndBack(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Edit plan'));
    await tester.pumpAndSettle();
    expect(find.text('plan-page'), findsOneWidget);
    clearInteractions(bloc);
    await tester.tap(find.text('plan-page'));
    await tester.pumpAndSettle();
  }

  testWidgets('Edit plan opens the plan and reloads after a save', (
    tester,
  ) async {
    await pumpList(tester, saved: true);
    await openPlanAndBack(tester);

    verify(() => bloc.add(const LoadBudgets())).called(1);
  });

  testWidgets('backing out without saving does not reload', (tester) async {
    await pumpList(tester, saved: false);
    await openPlanAndBack(tester);

    verifyNever(() => bloc.add(const LoadBudgets()));
  });
}
