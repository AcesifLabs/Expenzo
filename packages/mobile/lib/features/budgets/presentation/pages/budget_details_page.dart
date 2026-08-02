import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/constants/budget_ui_tokens.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_progress_colors.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';

class BudgetDetailsPage extends StatefulWidget {
  final BudgetProgress? progress;
  final String? budgetId;

  const BudgetDetailsPage({super.key, this.progress, this.budgetId});

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  BudgetProgress? _progress;
  String _name = 'Budget Details';
  var _isLoading = false;
  String? _errorMessage;
  var _transactionsDispatched = false;
  StreamSubscription<BudgetState>? _budgetLoadedSub;

  String get _budgetId => widget.progress?.budgetId ?? widget.budgetId ?? '';

  @override
  void initState() {
    super.initState();
    final existingProgress = widget.progress;
    if (existingProgress != null) {
      _progress = existingProgress;
      _name = existingProgress.name;
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
          _errorMessage = 'Unable to load budget details. Please try again.';
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
            _errorMessage = 'Budget not found.';
          });

          return;
        }

        final matchedProgress = progress;
        setState(() {
          _progress = matchedProgress;
          _name = matchedProgress.name;
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              PiconsRegular.caretLeft,
              size: 24,
              color: BudgetUiTokens.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _name,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: BudgetUiTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(BudgetProgress progress) {
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: fmt.format(progress.spentAmount),
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: BudgetUiTokens.textPrimary,
            ),
            children: [
              TextSpan(
                text: ' / ${fmt.format(progress.effectiveAmount)}',
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: BudgetUiTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${progress.period.displayName} budget',
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 13,
            color: BudgetUiTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percentage, Color progressColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: BudgetUiTokens.progressTrack,
          color: progressColor,
        ),
      ),
    );
  }

  Widget _buildStatusRow(BudgetProgress progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${progress.percentage.toStringAsFixed(0)}% used',
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 13,
            color: BudgetUiTokens.textSecondary,
          ),
        ),
        if (progress.isOverBudget)
          const Text(
            'OVER BUDGET',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: BudgetUiTokens.error,
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final progress = _progress;
    if (progress == null) return const SizedBox.shrink();

    final percentage = progress.percentage.clamp(0.0, 100.0);
    final progressColor = budgetProgressColor(progress.percentage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BudgetUiTokens.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountRow(progress),
          const SizedBox(height: 24),
          _buildProgressBar(percentage, progressColor),
          const SizedBox(height: 12),
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
          const Icon(
            PiconsRegular.warningCircle,
            size: 40,
            color: BudgetUiTokens.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load transactions',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: BudgetUiTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 13,
              color: BudgetUiTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _onRetryTransactions,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BudgetUiTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
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

    return Scaffold(
      backgroundColor: BudgetUiTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const Spacer(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      PiconsRegular.warningCircle,
                      size: 48,
                      color: BudgetUiTokens.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Unable to load budget',
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: BudgetUiTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Budget details could not be loaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        color: BudgetUiTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (budgetId.isNotEmpty)
                      ElevatedButton(
                        onPressed: () => _onRetryBudget(budgetId),
                        child: const Text('Retry'),
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
      backgroundColor: BudgetUiTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              ShimmerBox.rectangle(
                width: double.infinity,
                height: 180,
                borderRadius: 24,
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
      backgroundColor: BudgetUiTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildSummaryCard(),
              _buildTransactionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
