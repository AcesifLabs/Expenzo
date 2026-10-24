import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/core_screens.dart';
import '../../../support/factories/budget_factory.dart';
import '../../../support/factories/family_factory.dart';
import '../../../support/pump_localized.dart';

void main() {
  setUp(() {
    // I am a Member (user-2); bud-1 is the Admin's Shared Budget.
    di.getIt.registerSingleton(
      BudgetAccess(
        currentGroup: () =>
            makeMyGroup(myUserId: 'user-2', myRole: GroupRole.member),
      ),
    );
  });
  tearDown(() => di.getIt.unregister<BudgetAccess>());

  Future<void> pumpForm(WidgetTester tester, {String? groupId}) {
    final budget = makeBudget(id: 'bud-1', name: 'Groceries', groupId: groupId);

    return pumpLocalized(
      tester,
      BudgetFormPage(budget: budget),
      wrap: (app) => BlocProvider<BudgetBloc>.value(
        value: mockBloc<MockBudgetBloc, BudgetState>(
          MockBudgetBloc(),
          BudgetLoaded([budget]),
        ),
        child: app,
      ),
    );
  }

  testWidgets('a member opening the admin shared budget cannot change it', (
    tester,
  ) async {
    await pumpForm(tester, groupId: 'group-1');

    expect(find.text(t.budgets.form.sharedReadOnly), findsOneWidget);
    expect(find.text(t.common.save), findsNothing);
    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.every((field) => field.readOnly), isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });

  testWidgets('a personal budget stays editable', (tester) async {
    await pumpForm(tester);

    expect(find.text(t.budgets.form.sharedReadOnly), findsNothing);
    expect(find.text(t.common.save), findsOneWidget);
  });
}
