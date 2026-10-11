import 'dart:async';
import 'package:expense_tracker/core/constants/budget_period.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_progress_colors.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_display_name.dart';

class BudgetDetailsPage extends StatefulWidget {
  final BudgetProgress? progress;
  final String? budgetId;

  const BudgetDetailsPage({super.key, this.progress, this.budgetId});

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  BudgetProgress? _progress;
  String _name = t.budgets.details.title;
  var _isLoading = false;
  String? _errorMessage;
  var _transactionsDispatched = false;
  StreamSubscription<BudgetState>? _budgetLoadedSub;

  String get _budgetId => widget.progress?.budgetId ?? widget.budgetId ?? '';

  AppPalette get _palette => context.palette;

  @override
  void initState() {
    super.initState();
    final existingProgress = widget.progress;
    if (existingProgress != null) {
      _progress = existingProgress;
      _name = budgetDisplayName(existingProgress.name);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatchLoadTransactions(existingProgress.budgetId);
      });
    } else if (widget.budgetId != null) {
      _isLoading = true;
      _loadBudgetData(widget.budgetId ?? '');
    }
  }

  Future<void> _loadBudgetData(String budgetId) async {
    final getBudgetsWithProgress = di.getIt<GetBudgetsWithProgress>();
    final result = await getBudgetsWithProgress();

    if (!mounted) return;

    result.fold(
      (failure) {
        appLogger.error(
          'BudgetDetailsPage: Failed to load budget progress: ${failure.message}',
        );
        setState(() {
          _isLoading = false;
          _errorMessage = t.budgets.details.loadFailed;
        });
      },
      (progressList) {
        BudgetProgress? progress;
        for (final p in progressList) {
          if (p.budgetId == budgetId) {
            progress = p;
            break;
          }
        }

        if (progress == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = t.budgets.details.notFound;
          });

          return;
        }

        final matchedProgress = progress;
        setState(() {
          _progress = matchedProgress;
          _name = budgetDisplayName(matchedProgress.name);
          _isLoading = false;
          _errorMessage = null;
        });
        _dispatchLoadTransactions(matchedProgress.budgetId);
      },
    );
  }

  void _dispatchLoadTransactions(String budgetId) {
    if (!mounted || budgetId.isEmpty) return;

    final bloc = context.read<BudgetBloc>();
    void dispatch() {
      if (!mounted || _transactionsDispatched) return;
      _transactionsDispatched = true;
      bloc.add(LoadBudgetTransactions(budgetId));
    }

    if (bloc.state is BudgetLoaded) {
      dispatch();

      return;
    }

    _budgetLoadedSub?.cancel();
    _budgetLoadedSub = bloc.stream.listen((state) {
      if (state is BudgetLoaded) {
        dispatch();
        _budgetLoadedSub?.cancel();
        _budgetLoadedSub = null;
      }
    });
  }

  void _onRetryTransactions() {
    final budgetId = _budgetId;
    if (budgetId.isEmpty) return;
    setState(() => _transactionsDispatched = false);
    _dispatchLoadTransactions(budgetId);
  }

  void _onRetryBudget(String budgetId) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _transactionsDispatched = false;
    });
    _loadBudgetData(budgetId);
  }

  PreferredSizeWidget _buildTopBar() {
    return AppPageHeader(leading: const AppBackButton(), title: _name);
  }

  Widget _buildAmountRow(BudgetProgress progress) {
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);
    final strings = t.budgets.details;
    final periodBudget = strings.periodBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: fmt.format(progress.spentAmount),
            style: AppTypography.headlineSmall.copyWith(
              color: _palette.textPrimary,
            ),
            children: [
              TextSpan(
                text: strings.ofTotal(
                  total: fmt.format(progress.effectiveAmount),
                ),
                style: AppTypography.headlineSmall.copyWith(
                  color: _palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          switch (progress.period) {
            BudgetPeriod.weekly => periodBudget.weekly,
            BudgetPeriod.monthly => periodBudget.monthly,
            BudgetPeriod.yearly => periodBudget.yearly,
          },
          style: AppTypography.bodyMedium.copyWith(
            color: _palette.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percentage, Color progressColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: SizedBox(
        height: 12,
        child: LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: _palette.progressTrack,
          color: progressColor,
        ),
      ),
    );
  }

  Widget _buildStatusRow(BudgetProgress progress) {
    final strings = t.budgets.details;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          strings.used(percent: progress.percentage.toStringAsFixed(0)),
          style: AppTypography.bodyMedium.copyWith(
            color: _palette.textSecondary,
          ),
        ),
        if (progress.isOverBudget)
          Text(
            strings.over,
            style: AppTypography.labelLarge.copyWith(color: _palette.error),
          ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final progress = _progress;
    if (progress == null) return const SizedBox.shrink();

    final percentage = progress.percentage.clamp(0.0, 100.0);
    final progressColor = budgetProgressColor(_palette, progress.percentage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountRow(progress),
          const SizedBox(height: AppSpacing.lg),
          _buildProgressBar(percentage, progressColor),
          const SizedBox(height: AppSpacing.smd),
          _buildStatusRow(progress),
        ],
      ),
    );
  }

  Widget _buildTransactionsError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PiconsRegular.warningCircle,
            size: 40,
            color: _palette.textSecondary,
          ),
          const SizedBox(height: AppSpacing.smd),
          Text(
            t.budgets.details.transactionsFailed,
            style: AppTypography.titleMedium.copyWith(
              color: _palette.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: _palette.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _onRetryTransactions,
            child: Text(t.common.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTransactions() {
    final textTheme = Theme.of(context).textTheme;
    final strings = t.budgets.details;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.noExpenses, style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.noExpensesBody,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: _palette.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            icon: const Icon(PiconsRegular.plus, size: 18),
            label: Text(t.common.addExpense),
            onPressed: () => unawaited(_addExpense()),
          ),
        ],
      ),
    );
  }

  Future<void> _addExpense() async {
    final saved = await showTransactionSheet(context, budgetId: _budgetId);
    if (!saved || !mounted) return;
    _onRetryBudget(_budgetId);
  }

  Widget _buildTransactionsSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.budgets.details.transactions,
              style: AppTypography.titleMedium.copyWith(
                color: _palette.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.smd),
            Expanded(
              child: BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  if (state is! BudgetLoaded ||
                      state.selectedBudgetId != _budgetId) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.isLoadingTransactions) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final error = state.transactionsError;
                  if (error != null) {
                    return _buildTransactionsError(error);
                  }

                  if (state.selectedBudgetTransactions.isEmpty) {
                    return _buildNoTransactions();
                  }

                  return BudgetTransactionList(
                    records: state.selectedBudgetTransactions,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final budgetId = widget.budgetId ?? '';
    final strings = t.budgets.details;

    return Scaffold(
      backgroundColor: _palette.bg,
      appBar: _buildTopBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PiconsRegular.warningCircle,
                      size: 48,
                      color: _palette.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _errorMessage ?? strings.unableToLoad,
                      style: AppTypography.titleLarge.copyWith(
                        color: _palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      strings.unableToLoadBody,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: _palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (budgetId.isNotEmpty)
                      ElevatedButton(
                        onPressed: () => _onRetryBudget(budgetId),
                        child: Text(t.common.tryAgain),
                      ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: _palette.bg,
      appBar: _buildTopBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox.rectangle(
                width: double.infinity,
                height: 180,
                borderRadius: AppSpacing.radiusCard,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetLoadedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: _palette.bg,
      appBar: _buildTopBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildSummaryCard(), _buildTransactionsSection()],
          ),
        ),
      ),
    );
  }
}
