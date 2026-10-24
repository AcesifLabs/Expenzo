import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/core_screens.dart';
import '../../../support/factories/budget_factory.dart';
import '../../../support/factories/family_factory.dart';
import '../../../support/pump_localized.dart';

class _FakeBudgetEvent extends Fake implements BudgetEvent {}

void main() {
  late MockBudgetBloc bloc;
  MyGroup? group;

  setUpAll(() => registerFallbackValue(_FakeBudgetEvent()));

  setUp(() {
    group = null;
    di.getIt.registerSingleton(BudgetAccess(currentGroup: () => group));
    bloc = mockBloc<MockBudgetBloc, BudgetState>(
      MockBudgetBloc(),
      const BudgetLoaded([]),
    );
    when(() => bloc.add(any())).thenReturn(null);
  });
  tearDown(() => di.getIt.unregister<BudgetAccess>());

  Future<void> pumpForm(WidgetTester tester, {Budget? budget}) => pumpLocalized(
    tester,
    BudgetFormPage(budget: budget),
    wrap: (app) => BlocProvider<BudgetBloc>.value(value: bloc, child: app),
  );

  Finder shareSwitch() => find.descendant(
    of: find.ancestor(
      of: find.text(t.budgets.form.share),
      matching: find.byType(Row),
    ),
    matching: find.byType(Switch),
  );

  testWidgets('a member does not see the switch on their personal budget', (
    tester,
  ) async {
    group = makeMyGroup(myRole: GroupRole.member);
    await pumpForm(tester, budget: makeBudget(id: 'own'));

    expect(find.text(t.budgets.form.share), findsNothing);
  });

  testWidgets('an admin shares a new budget into the group on save', (
    tester,
  ) async {
    group = makeMyGroup();
    await pumpForm(tester);
    await tester.enterText(find.byType(TextFormField).at(0), '500');
    await tester.enterText(find.byType(TextFormField).at(1), 'Groceries');

    await tester.tap(shareSwitch());
    await tester.pump();
    // The page title reads the same; the button is in the scrolling body.
    final submit = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.text(t.budgets.form.add),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    final event =
        verify(() => bloc.add(captureAny())).captured.single
            as CreateBudgetEvent;
    expect(event.budget.groupId, 'group-1');
  });

  testWidgets('turning sharing off on a shared budget asks first', (
    tester,
  ) async {
    group = makeMyGroup();
    await pumpForm(
      tester,
      budget: makeBudget(id: 'bud-1', groupId: 'group-1'),
    );

    await tester.ensureVisible(shareSwitch());
    await tester.tap(shareSwitch());
    await tester.pumpAndSettle();

    expect(find.text(t.budgets.form.unshareTitle), findsOneWidget);
  });

  testWidgets('a demoted owner can switch sharing off but not on', (
    tester,
  ) async {
    // user-1 owns bud-1 but is now a Viewer.
    group = makeMyGroup(myRole: GroupRole.viewer);
    await pumpForm(
      tester,
      budget: makeBudget(id: 'bud-1', groupId: 'group-1'),
    );

    expect(tester.widget<Switch>(shareSwitch()).onChanged, isNotNull);

    await tester.ensureVisible(shareSwitch());
    await tester.tap(shareSwitch());
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.budgets.form.unshareConfirm));
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(shareSwitch()).value, isFalse);
    expect(tester.widget<Switch>(shareSwitch()).onChanged, isNull);
  });

  testWidgets('saving an owner edit keeps the groupId when the row is hidden', (
    tester,
  ) async {
    // A Viewer who owns nothing listed: no row, groupId stays.
    group = makeMyGroup(myRole: GroupRole.viewer, sharedBudgets: const []);
    final budget = makeBudget(id: 'own', name: 'Fuel', groupId: null);
    await pumpForm(tester, budget: budget);

    await tester.ensureVisible(find.text(t.common.save));
    await tester.tap(find.text(t.common.save));
    await tester.pump();

    final event =
        verify(() => bloc.add(captureAny())).captured.single
            as UpdateBudgetEvent;
    expect(event.budget.groupId, isNull);
  });
}
