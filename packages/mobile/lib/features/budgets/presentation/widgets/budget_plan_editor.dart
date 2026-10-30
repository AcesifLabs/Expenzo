import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/budget_plan.dart';
import '../../domain/entities/plan_row.dart';
import '../helpers/plan_row_colors.dart';

enum _PlanField { name, amount }

/// Editable Plan Rows with add, remove, Suggest split and a remaining
/// line. Shared by setup and Settings → Budget plan. The parent owns the
/// rows; this widget reports every change through [onChanged].
class BudgetPlanEditor extends StatefulWidget {
  final List<PlanRow> rows;
  final double base;
  final ValueChanged<List<PlanRow>> onChanged;
  final bool allowZero;

  const BudgetPlanEditor({
    super.key,
    required this.rows,
    required this.base,
    required this.onChanged,
    required this.allowZero,
  });

  @override
  State<BudgetPlanEditor> createState() => BudgetPlanEditorState();
}

class BudgetPlanEditorState extends State<BudgetPlanEditor> {
  static String _amountText(double amount) {
    if (amount <= 0) return '';

    return amount == amount.truncateToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
  }

  final _names = <String, TextEditingController>{};
  final _amounts = <String, TextEditingController>{};
  final _touched = <(String, _PlanField)>{};
  var _revealAll = false;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  /// Shows every row's errors, after a Continue or Save that failed
  /// validation.
  void revealErrors() => setState(() => _revealAll = true);

  void _syncControllers() {
    final keys = {for (final row in widget.rows) row.key};
    final gone = [
      for (final key in _names.keys)
        if (!keys.contains(key)) key,
    ];
    final stale = [
      for (final key in gone) ...[_names.remove(key), _amounts.remove(key)],
    ];
    _touched.removeWhere((field) => gone.contains(field.$1));
    // The removed rows' fields are still mounted until the next frame.
    if (stale.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final controller in stale) {
          controller?.dispose();
        }
      });
    }
    for (final row in widget.rows) {
      final name = _names.putIfAbsent(
        row.key,
        () => TextEditingController(text: row.name),
      );
      if (name.text != row.name) name.text = row.name;
      final amount = _amounts.putIfAbsent(
        row.key,
        () => TextEditingController(text: _amountText(row.amount)),
      );
      if ((parseAmountInput(amount.text) ?? 0) != row.amount) {
        amount.text = _amountText(row.amount);
      }
    }
  }

  void _change(String key, PlanRow Function(PlanRow row) update) =>
      widget.onChanged([
        for (final row in widget.rows) row.key == key ? update(row) : row,
      ]);

  void _onName(String key, String text) {
    _touched.add((key, _PlanField.name));
    _change(key, (row) => row.copyWith(name: text));
  }

  void _onAmount(String key, String text) {
    _touched.add((key, _PlanField.amount));
    _change(key, (row) => row.copyWith(amount: parseAmountInput(text) ?? 0));
  }

  void _onAdd() => widget.onChanged([...widget.rows, newPlanRow()]);

  void _onRemove(String key) =>
      widget.onChanged([...widget.rows.where((row) => row.key != key)]);

  void _onSuggest() =>
      widget.onChanged(rescaleToBase(widget.rows, widget.base));

  String? _nameError(PlanRow row, Set<PlanRowError> errors) {
    final shown = _revealAll || _touched.contains((row.key, _PlanField.name));
    if (!shown) return null;
    final planT = t.budgets.plan;
    final formT = t.budgets.form;

    for (final error in errors) {
      switch (error) {
        case PlanRowError.nameRequired:
          return formT.nameRequired;
        case PlanRowError.nameReserved:
          return formT.nameReserved;
        case PlanRowError.nameTooLong:
          return planT.nameTooLong(max: AppConstants.budgetNameMaxLength);
        case PlanRowError.nameDuplicate:
          return planT.nameDuplicate;
        case PlanRowError.amountInvalid:
          continue;
      }
    }

    return null;
  }

  String? _amountError(PlanRow row, Set<PlanRowError> errors) {
    final shown = _revealAll || _touched.contains((row.key, _PlanField.amount));
    if (!shown || !errors.contains(PlanRowError.amountInvalid)) return null;

    return widget.allowZero
        ? t.budgets.form.amountInvalid
        : t.budgets.plan.amountPositive;
  }

  Widget _buildRow(PlanRow row, Color color, Set<PlanRowError> errors) {
    final planT = t.budgets.plan;
    final name = row.name.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: AppSpacing.smd),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _names[row.key],
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  AppConstants.budgetNameMaxLength,
                ),
              ],
              decoration: InputDecoration(
                labelText: planT.name,
                errorText: _nameError(row, errors),
                errorMaxLines: 2,
              ),
              onChanged: (text) => _onName(row.key, text),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _amounts[row.key],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [amountInputFormatter],
              decoration: InputDecoration(
                labelText: planT.amount,
                hintText: '0',
                prefixText: '${CurrencyFormatter.current.value.symbol.trim()} ',
                errorText: _amountError(row, errors),
                errorMaxLines: 2,
              ),
              onChanged: (text) => _onAmount(row.key, text),
            ),
          ),
          IconButton(
            tooltip: name.isEmpty
                ? planT.removeUnnamed
                : planT.removeBudget(name: name),
            icon: const Icon(PiconsRegular.x),
            onPressed: () => _onRemove(row.key),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final planT = t.budgets.plan;
    final remaining = planRemaining(widget.base, widget.rows);
    final palette = context.palette;
    final over = remaining < 0;

    return Text(
      over
          ? planT.overBy(amount: CurrencyFormatter.format(-remaining))
          : planT.remaining(amount: CurrencyFormatter.format(remaining)),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: over ? palette.warning : palette.textSecondary,
      ),
    );
  }

  @override
  void didUpdateWidget(BudgetPlanEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in [..._names.values, ..._amounts.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planT = t.budgets.plan;
    final colors = planRowColors(context.palette);
    final errors = validatePlan(widget.rows, allowZero: widget.allowZero);
    final canSuggest = widget.base > 0 && widget.rows.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in widget.rows.indexed)
          _buildRow(row, colors[index % colors.length], errors[row.key] ?? {}),
        if (widget.base > 0) _buildSummary(context),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(PiconsRegular.plus, size: 18),
              label: Text(planT.addBudget),
              onPressed: _onAdd,
            ),
            TextButton.icon(
              icon: const Icon(PiconsRegular.sparkle, size: 18),
              label: Text(planT.suggestSplit),
              onPressed: canSuggest ? _onSuggest : null,
            ),
          ],
        ),
      ],
    );
  }
}
