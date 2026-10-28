import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/all_budgets_picker_page.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../support/factories/family_factory.dart';
import '../../../support/pump_localized.dart';

class _MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

BudgetProgress _progress({
  required String id,
  required String name,
  double spent = 120,
  double limit = 500,
  String? groupId,
}) {
  return BudgetProgress(
    budgetId: id,
    budgetAmount: limit,
    effectiveAmount: limit,
    spentAmount: spent,
    rolloverAmount: 0,
    percentage: spent / limit * 100,
    isOverBudget: spent > limit,
    name: name,
    periodRange: DateTimeRange(
      start: DateTime(2026, 10),
      end: DateTime(2026, 11),
    ),
    period: BudgetPeriod.monthly,
    groupId: groupId,
  );
}

void main() {
  late _MockGetBudgetsWithProgress getBudgetsWithProgress;

  setUp(() {
    CurrencyFormatter.current.value = CurrencyConfig.byCode('BDT');
    getBudgetsWithProgress = _MockGetBudgetsWithProgress();
    di.getIt.registerSingleton<GetBudgetsWithProgress>(getBudgetsWithProgress);
  });

  tearDown(() async {
    await di.getIt.unregister<GetBudgetsWithProgress>();
  });

  void stubBudgets(List<BudgetProgress> budgets) {
    when(
      () => getBudgetsWithProgress(),
    ).thenAnswer((_) async => Right(budgets));
  }

  Future<List<String?>> openPicker(
    WidgetTester tester, {
    String? selectedId,
  }) async {
    final popped = <String?>[];
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => AllBudgetsPickerPage(selectedId: selectedId),
              ),
            );
            popped.add(result);
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    return popped;
  }

  testWidgets('lists budgets with their period and spending', (tester) async {
    stubBudgets([_progress(id: 'b1', name: 'Food')]);

    await openPicker(tester);

    expect(find.text(t.budgets.picker.title), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(
      find.text(
        t.budgets.picker.progress(
          period: BudgetPeriod.monthly.displayName,
          spent: CurrencyFormatter.format(120, decimalDigits: 0),
          limit: CurrencyFormatter.format(500, decimalDigits: 0),
        ),
      ),
      findsOneWidget,
    );
  });

  for (final (role, listsShared) in [
    (GroupRole.viewer, false),
    (GroupRole.member, true),
  ]) {
    testWidgets('a ${role.name} sees shared budgets: $listsShared', (
      tester,
    ) async {
      di.getIt.registerSingleton(
        BudgetAccess(currentGroup: () => makeMyGroup(myRole: role)),
      );
      addTearDown(() => di.getIt.unregister<BudgetAccess>());
      stubBudgets([
        _progress(id: 'b1', name: 'Food'),
        _progress(id: 'b2', name: 'Rent', groupId: 'group-1'),
      ]);

      await openPicker(tester);

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Rent'), listsShared ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('marks only the selected budget', (tester) async {
    stubBudgets([
      _progress(id: 'b1', name: 'Food'),
      _progress(id: 'b2', name: 'Travel'),
    ]);

    await openPicker(tester, selectedId: 'b2');

    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);
    expect(
      find.descendant(
        of: find.ancestor(of: find.text('Travel'), matching: find.byType(Row)),
        matching: find.byIcon(PiconsRegular.checkCircle),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a budget pops its id', (tester) async {
    stubBudgets([_progress(id: 'b1', name: 'Food')]);

    final popped = await openPicker(tester);
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(popped, ['b1']);
  });

  testWidgets('tapping No budget pops an empty id', (tester) async {
    stubBudgets([_progress(id: 'b1', name: 'Food')]);

    final popped = await openPicker(tester, selectedId: 'b1');
    await tester.tap(find.text(t.budgets.picker.noBudget));
    await tester.pumpAndSettle();

    expect(popped, ['']);
  });

  testWidgets('an inactive link shows as the selected previous budget', (
    tester,
  ) async {
    stubBudgets([_progress(id: 'b1', name: 'Food')]);

    final popped = await openPicker(tester, selectedId: 'disabled-budget');

    final previousRow = find.ancestor(
      of: find.text(t.budgets.picker.previousBudget),
      matching: find.byType(Row),
    );
    expect(
      find.descendant(
        of: previousRow,
        matching: find.byIcon(PiconsRegular.checkCircle),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);

    await tester.tap(find.text(t.budgets.picker.previousBudget));
    await tester.pumpAndSettle();

    expect(popped, ['disabled-budget']);
  });

  testWidgets('no previous budget row when the link is active or empty', (
    tester,
  ) async {
    stubBudgets([_progress(id: 'b1', name: 'Food')]);

    await openPicker(tester, selectedId: 'b1');

    expect(find.text(t.budgets.picker.previousBudget), findsNothing);
  });

  testWidgets('closing without choosing pops null', (tester) async {
    stubBudgets([_progress(id: 'b1', name: 'Food')]);

    final popped = await openPicker(tester);
    await tester.tap(find.byIcon(PiconsRegular.x));
    await tester.pumpAndSettle();

    expect(popped, [null]);
  });

  testWidgets('shows the empty message when there are no budgets', (
    tester,
  ) async {
    stubBudgets([]);

    await openPicker(tester);

    expect(find.text(t.budgets.picker.noBudget), findsOneWidget);
    expect(find.text(t.budgets.picker.empty), findsOneWidget);
  });

  testWidgets('a load failure shows localized error text', (tester) async {
    when(
      () => getBudgetsWithProgress(),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db locked')));

    await openPicker(tester);

    expect(find.text(t.common.errors.storage), findsOneWidget);
    expect(find.text('db locked'), findsNothing);
  });
}
