import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/constants/budget_ui_tokens.dart';

/// Full-screen budget picker (`AllBudgetsPicker` in expenzo.pen).
class AllBudgetsPickerPage extends StatefulWidget {
  final String? selectedId;

  const AllBudgetsPickerPage({super.key, this.selectedId});

  @override
  State<AllBudgetsPickerPage> createState() => _AllBudgetsPickerPageState();
}

class _AllBudgetsPickerPageState extends State<AllBudgetsPickerPage> {
  var _loading = true;
  String? _error;
  List<BudgetProgress> _budgets = const [];
  late String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    _load();
  }

  Future<void> _load() async {
    final result = await di.getIt<GetBudgetsWithProgress>()();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (list) => setState(() {
        _loading = false;
        _budgets = list;
      }),
    );
  }

  void _selectNoBudget() {
    setState(() => _selectedId = null);
    context.pop('');
  }

  void _selectBudget(String id) {
    setState(() => _selectedId = id);
    context.pop(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetUiTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 8),
              const Text(
                'Select which budgets this expense should count toward',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: BudgetUiTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AVAILABLE BUDGETS',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: BudgetUiTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(
            PiconsRegular.x,
            size: 24,
            color: BudgetUiTokens.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Assign Budgets',
          style: TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: BudgetUiTokens.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: BudgetUiTokens.textSecondary,
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 14,
            color: BudgetUiTokens.textSecondary,
          ),
        ),
      );
    }

    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);

    return ListView(
      children: [
        _BudgetPickerRow(
          selected: _selectedId == null,
          title: 'No budget',
          subtitle: 'Do not link to a budget',
          progress: null,
          onTap: _selectNoBudget,
        ),
        for (final progress in _budgets)
          _BudgetPickerRow(
            selected: progress.budgetId == _selectedId,
            title: progress.name,
            subtitle:
                '${progress.period.displayName} · '
                '${fmt.format(progress.spentAmount)} / '
                '${fmt.format(progress.effectiveAmount)}',
            progress: progress.percentage.clamp(0, 100) / 100,
            onTap: () => _selectBudget(progress.budgetId),
          ),
      ],
    );
  }
}

class _BudgetPickerRow extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final double? progress;
  final VoidCallback onTap;

  const _BudgetPickerRow({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BudgetUiTokens.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: BudgetUiTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 12,
                        color: BudgetUiTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (progress != null) ...[
                const SizedBox(width: 8),
                _PctBar(fraction: progress!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? BudgetUiTokens.primary : Colors.transparent,
        border: Border.all(
          color: selected
              ? BudgetUiTokens.primary
              : BudgetUiTokens.textSecondary,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: BudgetUiTokens.onPrimary,
              ),
            )
          : null,
    );
  }
}

class _PctBar extends StatelessWidget {
  final double fraction;

  const _PctBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    const width = 40.0;
    const height = 6.0;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            Container(color: BudgetUiTokens.progressTrack),
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(color: BudgetUiTokens.primary),
            ),
          ],
        ),
      ),
    );
  }
}
