import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/budget_plan.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/plan_row.dart';
import '../bloc/budget_plan_bloc.dart';
import '../bloc/budget_plan_event.dart';
import '../bloc/budget_plan_state.dart';
import '../helpers/budget_display_name.dart';
import '../widgets/budget_plan_editor.dart';
import '../widgets/plan_donut.dart';

/// Settings → Budget plan: monthly income and every personal monthly
/// budget, edited together. Pops `true` after a save.
class BudgetPlanPage extends StatefulWidget {
  const BudgetPlanPage({super.key});

  @override
  State<BudgetPlanPage> createState() => _BudgetPlanPageState();
}

class _BudgetPlanPageState extends State<BudgetPlanPage> {
  final _income = TextEditingController();
  final _editor = GlobalKey<BudgetPlanEditorState>();
  var _confirming = false;

  @override
  void initState() {
    super.initState();
    context.read<BudgetPlanBloc>().add(const BudgetPlanLoadRequested());
  }

  BudgetPlanBloc get _bloc => context.read<BudgetPlanBloc>();

  /// True for every fresh load, including the reload after a failed save,
  /// which can bring back the same stored plan.
  bool _loaded(BudgetPlanState previous, BudgetPlanState current) =>
      current is BudgetPlanEditing &&
      (previous is! BudgetPlanEditing ||
          previous.stored != current.stored ||
          previous.status == BudgetPlanSaveStatus.failed);

  void _onLoaded(BuildContext _, BudgetPlanState state) {
    if (state is! BudgetPlanEditing) return;
    final income = state.income;
    _income.text = income == null || income <= 0
        ? ''
        : income.toStringAsFixed(2);
  }

  bool _statusChanged(BudgetPlanState previous, BudgetPlanState current) =>
      current is BudgetPlanEditing &&
      (previous is! BudgetPlanEditing || previous.status != current.status);

  void _onStatus(BuildContext context, BudgetPlanState state) {
    if (state is! BudgetPlanEditing) return;
    final planT = t.budgets.plan;
    final messenger = ScaffoldMessenger.of(context);
    switch (state.status) {
      case BudgetPlanSaveStatus.saved:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(planT.saved)));
        context.pop(true);
      case BudgetPlanSaveStatus.failed:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(planT.saveFailed)));
      case BudgetPlanSaveStatus.idle || BudgetPlanSaveStatus.saving:
        break;
    }
  }

  void _onIncome(String text) =>
      _bloc.add(BudgetPlanIncomeChanged(parseAmountInput(text)));

  void _onRows(List<PlanRow> rows) => _bloc.add(BudgetPlanRowsChanged(rows));

  void _onRetry() => _bloc.add(const BudgetPlanLoadRequested());

  Future<void> _onSave(BudgetPlanEditing state) async {
    if (_confirming) return;
    if (validatePlan(state.rows, allowZero: false).isNotEmpty) {
      _editor.currentState?.revealErrors();

      return;
    }
    final bloc = _bloc;
    final changes = diffPlan(state.stored.budgets, state.rows, clock.now());
    final removed = changes.toDelete;
    if (removed.isNotEmpty) {
      _confirming = true;
      final confirmed = await _confirmDelete(removed);
      _confirming = false;
      if (!confirmed) return;
    }
    bloc.add(BudgetPlanSaveRequested(changes));
  }

  Future<bool> _confirmDelete(List<Budget> removed) async {
    final planT = t.budgets.plan;
    final names = removed.map((b) => budgetDisplayName(b.name)).join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(planT.deleteTitle),
        content: Text(planT.deleteBody(names: names)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Widget _buildIncome(BudgetPlanEditing state) {
    final planT = t.budgets.plan;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _income,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [amountInputFormatter],
          decoration: InputDecoration(
            labelText: planT.income,
            prefixText: '${CurrencyFormatter.current.value.symbol.trim()} ',
          ),
          onChanged: _onIncome,
        ),
        if (state.base > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            planT.toPlan(amount: CurrencyFormatter.format(state.base)),
            style: textTheme.bodySmall?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditing(BudgetPlanEditing state) {
    final saving = state.status == BudgetPlanSaveStatus.saving;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.pagePadding,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _buildIncome(state),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: PlanDonut(rows: state.rows, base: state.base),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.rows.isEmpty) ...[
                Text(
                  t.budgets.plan.empty,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              BudgetPlanEditor(
                key: _editor,
                rows: state.rows,
                base: state.base,
                allowZero: false,
                onChanged: _onRows,
              ),
            ],
          ),
        ),
        Padding(
          padding: AppSpacing.pagePadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity,
              minHeight: AppSpacing.xxl,
            ),
            child: ElevatedButton(
              onPressed: saving ? null : () => _onSave(state),
              child: Text(t.common.save),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext _, BudgetPlanState state) {
    return switch (state) {
      BudgetPlanLoading() => const Center(child: CircularProgressIndicator()),
      BudgetPlanLoadFailed() => AppErrorState(
        message: t.budgets.plan.loadFailed,
        onRetry: _onRetry,
      ),
      final BudgetPlanEditing editing => _buildEditing(editing),
    };
  }

  @override
  void dispose() {
    _income.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: t.budgets.plan.title,
        leading: const AppBackButton(),
        child: MultiBlocListener(
          listeners: [
            BlocListener<BudgetPlanBloc, BudgetPlanState>(
              listenWhen: _loaded,
              listener: _onLoaded,
            ),
            BlocListener<BudgetPlanBloc, BudgetPlanState>(
              listenWhen: _statusChanged,
              listener: _onStatus,
            ),
          ],
          child: BlocBuilder<BudgetPlanBloc, BudgetPlanState>(
            builder: _buildBody,
          ),
        ),
      ),
    );
  }
}
