import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetDetailsPage extends StatefulWidget {
  final BudgetProgress? progress;
  final String? budgetId;

  const BudgetDetailsPage({super.key, this.progress, this.budgetId});

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  BudgetProgress? _progress;
  String? _categoryId;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existingProgress = widget.progress;
    if (existingProgress != null) {
      _progress = existingProgress;
      _categoryId = existingProgress.categoryId;
      _dispatchLoadTransactions(existingProgress.budgetId);
    } else if (widget.budgetId != null) {
      _isLoading = true;
      _loadBudgetData(widget.budgetId ?? '');
    }
  }

  Future<void> _loadBudgetData(String budgetId) async {
    try {
      final repo = di.getIt<BudgetRepository>();
      final budgetResult = await repo.getBudgetById(budgetId);
      if (!mounted) return;
      budgetResult.fold(
        (failure) {
          debugPrint(
            'BudgetDetailsPage: Failed to load budget: ${failure.message}',
          );
          setState(() => _isLoading = false);
        },
        (budget) {
          setState(() => _categoryId = budget.categoryId);
          _dispatchLoadTransactions(budgetId);
        },
      );
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _dispatchLoadTransactions(String budgetId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BudgetBloc>().add(LoadBudgetTransactions(budgetId));
      setState(() => _isLoading = false);
    });
  }

  Widget _buildProgressCard(NumberFormat fmt, ColorScheme colors) {
    final progress = _progress;
    if (progress == null) return const SizedBox.shrink();

    final percentage = progress.percentage;
    final alpha120 = colors.onSurface.withAlpha(120);

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '${fmt.format(progress.spentAmount)} / ${fmt.format(progress.budgetAmount)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.period.name} budget',
            style: TextStyle(fontSize: 14, color: alpha120),
          ),
          const SizedBox(height: 24),
          BudgetProgressIndicator(percentage: percentage),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}% used',
                style: TextStyle(fontSize: 13, color: alpha120),
              ),
              if (progress.isOverBudget)
                Text(
                  'OVER BUDGET',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String get _budgetId => widget.progress?.budgetId ?? widget.budgetId ?? '';

  Widget _buildTransactionsSection() {
    return Expanded(
      child: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoaded && state.selectedBudgetId == _budgetId) {
            if (state.isLoadingTransactions) {
              return const Center(child: CircularProgressIndicator());
            }

            return BudgetTransactionList(
              records: state.selectedBudgetTransactions,
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTransactionsHeader(ColorScheme colors) {
    final alpha120 = colors.onSurface.withAlpha(120);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Icon(PiconsLight.listDashes, size: 18, color: alpha120),
          const SizedBox(width: 8),
          Text(
            'Transactions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);
    final colors = Theme.of(context).colorScheme;
    final title = _categoryId ?? 'Budget Details';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: title,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _buildProgressCard(fmt, colors),
          ),
          _buildTransactionsHeader(colors),
          _buildTransactionsSection(),
        ],
      ),
    );
  }
}
