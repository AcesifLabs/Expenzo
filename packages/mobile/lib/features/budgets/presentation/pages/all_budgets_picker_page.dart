import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';

/// Full-screen budget picker (`AllBudgetsPicker` in expenzo.pen).
///
/// Pops the chosen budget's id, an empty string for "No budget", or `null`
/// when the user closes the page without choosing.
class AllBudgetsPickerPage extends StatefulWidget {
  final String? selectedId;

  const AllBudgetsPickerPage({super.key, this.selectedId});

  @override
  State<AllBudgetsPickerPage> createState() => _AllBudgetsPickerPageState();
}

class _AllBudgetsPickerPageState extends State<AllBudgetsPickerPage> {
  AppPalette get _palette => context.palette;

  var _loading = true;
  String? _errorText;
  List<BudgetProgress> _budgets = const [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final result = await di.getIt<GetBudgetsWithProgress>()();
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.fold(
        (failure) => _errorText = failureText(failure),
        (budgets) => _budgets = budgets,
      );
    });
  }

  void _onNoBudgetTap() {
    Navigator.pop(context, '');
  }

  void _onKeepLinkTap(String selectedId) {
    Navigator.pop(context, selectedId);
  }

  void _onBudgetTap(BudgetProgress budget) {
    Navigator.pop(context, budget.budgetId);
  }

  PreferredSizeWidget _buildTopBar() {
    final pickerT = t.budgets.picker;

    return AppPageHeader(
      leading: AppBackButton(icon: PiconsRegular.x),
      title: pickerT.title,
      subtitle: pickerT.subtitle,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _palette.textSecondary,
        ),
      );
    }

    final errorText = _errorText;
    if (errorText != null) {
      return Center(child: _buildSecondaryText(errorText));
    }

    final pickerT = t.budgets.picker;
    final selectedId = widget.selectedId;
    // An edited record can point at a budget that has since been disabled or
    // deleted. Show it as selected so the page doesn't read as "No budget".
    final hasInactiveLink =
        selectedId != null && !_budgets.any((b) => b.budgetId == selectedId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      children: [
        _buildSectionHeader(),
        _BudgetPickerRow(
          title: pickerT.noBudget,
          subtitle: pickerT.noBudgetHint,
          isSelected: selectedId == null,
          onTap: _onNoBudgetTap,
        ),
        if (hasInactiveLink)
          _BudgetPickerRow(
            title: pickerT.previousBudget,
            subtitle: pickerT.previousBudgetHint,
            isSelected: true,
            onTap: () => _onKeepLinkTap(selectedId),
          ),
        ..._budgets.map(_buildBudgetRow),
        if (_budgets.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Center(child: _buildSecondaryText(pickerT.empty)),
          ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        t.budgets.picker.sectionAvailable.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          letterSpacing: 0.05,
          color: _palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildBudgetRow(BudgetProgress budget) {
    return _BudgetPickerRow(
      title: budget.name,
      subtitle: t.budgets.picker.progress(
        period: budget.period.displayName,
        spent: CurrencyFormatter.format(budget.spentAmount, decimalDigits: 0),
        limit: CurrencyFormatter.format(
          budget.effectiveAmount,
          decimalDigits: 0,
        ),
      ),
      isSelected: budget.budgetId == widget.selectedId,
      percentage: budget.percentage,
      onTap: () => _onBudgetTap(budget),
    );
  }

  Widget _buildSecondaryText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.bodyMedium.copyWith(color: _palette.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.bg,
      appBar: _buildTopBar(),
      body: SafeArea(child: _buildBody()),
    );
  }
}

class _BudgetPickerRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final double? percentage;
  final VoidCallback onTap;

  const _BudgetPickerRow({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    this.percentage,
    required this.onTap,
  });

  Widget _buildLabels(AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              (isSelected ? AppTypography.titleSmall : AppTypography.bodyMedium)
                  .copyWith(color: palette.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final localPercentage = percentage;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: palette.surface,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTapTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.smd,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildLabels(palette)),
                  if (localPercentage != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 40,
                      child: BudgetProgressIndicator(
                        percentage: localPercentage,
                        height: 6,
                      ),
                    ),
                  ],
                  if (isSelected) ...[
                    const SizedBox(width: AppSpacing.smd),
                    Icon(
                      PiconsRegular.checkCircle,
                      size: 20,
                      color: palette.brand,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
