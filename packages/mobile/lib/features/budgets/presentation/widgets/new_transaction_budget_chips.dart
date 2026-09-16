import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/presentation/constants/budget_ui_tokens.dart';

/// Horizontal budget chips + "…" opener from `NewTransactionSheet` / `expenzo.pen`.
class NewTransactionBudgetChips extends StatelessWidget {
  final List<Budget> budgets;
  final bool loading;
  final String? selectedBudgetId;
  final ValueChanged<String?> onSelected;

  const NewTransactionBudgetChips({
    super.key,
    required this.budgets,
    required this.loading,
    required this.selectedBudgetId,
    required this.onSelected,
  });

  static const _chipRadius = 16.0;
  static const _moreSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: loading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BudgetUiTokens.textSecondary,
                        ),
                      ),
                    )
                  : budgets.isEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'No budgets yet',
                        style: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 12,
                          color: BudgetUiTokens.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: budgets.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        final id = budget.id;
                        if (id == null) return const SizedBox.shrink();

                        final selected = id == selectedBudgetId;

                        return _BudgetChip(
                          label: budget.name,
                          selected: selected,
                          onTap: () => onSelected(selected ? null : id),
                        );
                      },
                    ),
            ),
            if (!loading) ...[
              const SizedBox(width: 8),
              _MoreBudgetsButton(
                enabled: budgets.isNotEmpty,
                onTap: () => _openPicker(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await context.push<String?>(
      '/budgets/picker',
      extra: {'selectedId': selectedBudgetId},
    );
    if (picked == null) return;
    onSelected(picked.isEmpty ? null : picked);
  }
}

class _BudgetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BudgetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? BudgetUiTokens.primary : Colors.transparent;
    final bg = selected
        ? BudgetUiTokens.primary.withAlpha(0x20)
        : BudgetUiTokens.inputFill;
    final fg = selected ? BudgetUiTokens.primary : BudgetUiTokens.textSecondary;
    final weight = selected ? FontWeight.w600 : FontWeight.normal;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          NewTransactionBudgetChips._chipRadius,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(
              NewTransactionBudgetChips._chipRadius,
            ),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PiconsLight.wallet, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 12,
                  fontWeight: weight,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreBudgetsButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _MoreBudgetsButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Assign budget',
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(
            NewTransactionBudgetChips._moreSize / 2,
          ),
          child: Container(
            width: NewTransactionBudgetChips._moreSize,
            height: NewTransactionBudgetChips._moreSize,
            decoration: BoxDecoration(
              color: BudgetUiTokens.textSecondary.withAlpha(0x15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '...',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: enabled
                    ? BudgetUiTokens.textSecondary
                    : BudgetUiTokens.textSecondary.withAlpha(0x40),
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
