import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_plan_editor.dart';

import '../../../../support/pump_localized.dart';

class _Host extends StatefulWidget {
  final List<PlanRow> initial;
  final double base;
  final bool allowZero;

  const _Host({
    required this.initial,
    required this.base,
    this.allowZero = false,
  });

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final editorKey = GlobalKey<BudgetPlanEditorState>();
  late List<PlanRow> rows = widget.initial;

  void _onChanged(List<PlanRow> next) => setState(() => rows = next);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: BudgetPlanEditor(
        key: editorKey,
        rows: rows,
        base: widget.base,
        allowZero: widget.allowZero,
        onChanged: _onChanged,
      ),
    ),
  );
}

void main() {
  const food = PlanRow(key: 'f', name: 'Food', amount: 300);
  const rent = PlanRow(key: 'r', name: 'Rent', amount: 600);

  Future<_HostState> pump(
    WidgetTester tester, {
    List<PlanRow> rows = const [food, rent],
    double base = 1000,
    bool allowZero = false,
  }) async {
    await pumpLocalized(
      tester,
      _Host(initial: rows, base: base, allowZero: allowZero),
    );

    return tester.state<_HostState>(find.byType(_Host));
  }

  Finder field(String text) => find.widgetWithText(TextField, text);

  testWidgets('shows each row and what is left', (tester) async {
    await pump(tester);

    expect(field('Food'), findsOneWidget);
    expect(field('600'), findsOneWidget);
    expect(find.textContaining('100.00 left to assign'), findsOneWidget);
  });

  testWidgets('editing name and amount updates the rows', (tester) async {
    final host = await pump(tester);

    await tester.enterText(field('Food'), 'Groceries');
    await tester.enterText(field('300'), '450.5');
    await tester.pump();

    expect(host.rows.first, food.copyWith(name: 'Groceries', amount: 450.5));
    expect(find.textContaining('Over by'), findsOneWidget);
  });

  testWidgets('add appends an empty row; remove drops one', (tester) async {
    final host = await pump(tester);

    await tester.tap(find.text('Add budget'));
    await tester.pump();
    expect(host.rows, hasLength(3));
    expect(host.rows.last.name, isEmpty);

    await tester.tap(find.byTooltip('Remove Food'));
    await tester.pumpAndSettle();
    expect(host.rows.map((r) => r.key), ['r', host.rows.last.key]);
    expect(field('Rent'), findsOneWidget);
    expect(field('600'), findsOneWidget);
  });

  testWidgets('Suggest split rescales to the base', (tester) async {
    final host = await pump(tester, base: 1800);

    await tester.tap(find.text('Suggest split'));
    await tester.pump();

    expect(host.rows.map((r) => r.amount), [600, 1200]);
    expect(field('1200'), findsOneWidget);
  });

  testWidgets('no base hides the summary and disables Suggest split', (
    tester,
  ) async {
    await pump(tester, base: 0);

    expect(find.textContaining('left to assign'), findsNothing);
    final suggest = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('Suggest split'),
        matching: find.byWidgetPredicate((w) => w is TextButton),
      ),
    );
    expect(suggest.onPressed, isNull);
  });

  testWidgets('errors show after an edit, or all at once on reveal', (
    tester,
  ) async {
    final host = await pump(
      tester,
      rows: const [
        food,
        PlanRow(key: 'z', name: 'Zero', amount: 0),
      ],
    );

    expect(find.text('Enter an amount above 0'), findsNothing);

    await tester.enterText(field('Food'), 'zero');
    await tester.pump();
    expect(find.text('Another budget has this name'), findsOneWidget);

    host.editorKey.currentState?.revealErrors();
    await tester.pump();
    expect(find.text('Another budget has this name'), findsNWidgets(2));
    expect(find.text('Enter an amount above 0'), findsOneWidget);
  });

  testWidgets('setup allows 0 amounts', (tester) async {
    final host = await pump(
      tester,
      rows: const [PlanRow(key: 'z', name: 'Zero', amount: 0)],
      allowZero: true,
    );

    host.editorKey.currentState?.revealErrors();
    await tester.pump();

    expect(find.text('Enter an amount above 0'), findsNothing);
  });

  testWidgets('a half-typed amount keeps its value and text', (tester) async {
    final host = await pump(tester);

    await tester.enterText(field('300'), '12.');
    await tester.pump();

    expect(host.rows.first.amount, 12);
    expect(field('12.'), findsOneWidget);
  });
}
