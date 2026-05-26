import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_summary_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_section_header.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';
import '../../domain/entities/date_range.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final authState = context.watch<AuthBloc>().state;
        final name = authState is Authenticated
            ? (authState.user.displayName ?? 'User')
            : 'User';
        final photoUrl = authState is Authenticated
            ? authState.user.photoUrl
            : null;

        final now = DateTime.now();
        final day = now.day;
        final suffix = day % 10 == 1 && day != 11
            ? 'st'
            : day % 10 == 2 && day != 12
            ? 'nd'
            : day % 10 == 3 && day != 13
            ? 'rd'
            : 'th';
        final dateStr =
            '$day$suffix ${DateFormat('MMMM').format(now)}, '
            '${DateFormat('EEEE').format(now)}, ${now.year}';

        return AppScaffold.slivers(
          title: null,
          subtitle: dateStr,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => _buildMenuItems(context),
                padding: EdgeInsets.zero,
                icon: SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(30),
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? (authState is Authenticated
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    )
                                  : Icon(
                                      PhosphorIcons.user(
                                        PhosphorIconsStyle.regular,
                                      ),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 20,
                                    ))
                            : null,
                      ),
                      if (authState is AuthLoading)
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          slivers: _buildContent(context, state),
          onRefresh: () async {
            context.read<DashboardBloc>().add(RefreshDashboard());
          },
        );
      },
    );
  }

  List<Widget> _buildContent(BuildContext context, DashboardState state) {
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final colors = Theme.of(context).colorScheme;

    if (state is DashboardLoading) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildBalanceSkeleton(),
          ),
        ),
      ];
    }

    if (state is DashboardError) {
      return [
        SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(PhosphorIconsStyle.light),
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text('Error: ${state.message}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<DashboardBloc>().add(RefreshDashboard()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ];
    }

    if (state is DashboardLoaded) {
      final s = state.summary;
      return [
        // Balance Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: AppSummaryCard(
              title: 'Total Balance',
              value: currencyFmt.format(s.totalBalance),
              bottomChild: Row(
                children: [
                  _BalanceRow(
                    icon: PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
                    label: 'Income',
                    amount: s.totalIncome,
                    color: colors.secondary,
                    currencyFmt: currencyFmt,
                  ),
                  const SizedBox(width: 24),
                  _BalanceRow(
                    icon: PhosphorIcons.trendDown(PhosphorIconsStyle.fill),
                    label: 'Expense',
                    amount: s.totalExpense,
                    color: colors.error,
                    currencyFmt: currencyFmt,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Budgets section
        const SliverToBoxAdapter(child: SizedBox(height: 2)),
        const SliverToBoxAdapter(child: AppSectionHeader(title: 'Budgets')),
        _buildBudgetCards(context),
        // Recent Activity
        const SliverToBoxAdapter(child: SizedBox(height: 5)),
        const SliverToBoxAdapter(
          child: AppSectionHeader(title: 'Recent Activity'),
        ),
        if (s.recentTransactions.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: AppEmptyState(
                  icon: PhosphorIcons.tray(PhosphorIconsStyle.regular),
                  message: 'No transactions yet',
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppCard(
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 140,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: s.recentTransactions
                        .map((r) => _RecentTile(record: r, fmt: currencyFmt))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
      ];
    }

    // DashboardInitial — trigger load after initial queries settle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 450), () {
        if (context.mounted) {
          context.read<DashboardBloc>().add(
            const LoadDashboard(
              dateRange: DateRange(preset: DateRangePreset.thisMonth),
            ),
          );
        }
      });
    });

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildBalanceSkeleton(),
        ),
      ),
    ];
  }

  Widget _buildBudgetCards(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return FutureBuilder(
      future: di.featureDependenciesReady,
      builder: (context, ready) {
        if (ready.connectionState != ConnectionState.done) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildBudgetSkeleton(context),
            ),
          );
        }

        final getBudgetsWithProgress = _tryGetBudgetsWithProgress();
        if (getBudgetsWithProgress == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return FutureBuilder<List<BudgetProgress>>(
          future: getBudgetsWithProgress(
            limit: 5,
          ).then((result) => result.getOrElse(() => [])),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBudgetSkeleton(context),
                ),
              );
            }

            final budgets = snapshot.data ?? [];
            if (budgets.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: AppEmptyState(
                      icon: PhosphorIcons.tray(PhosphorIconsStyle.regular),
                      message: 'No budgets set',
                    ),
                  ),
                ),
              );
            }

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: budgets.map((bp) {
                      return _BudgetProgressCard(
                        progress: bp,
                        currencyFmt: currencyFmt,
                        onTap: () => _showBudgetTransactions(context, bp),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBudgetSkeleton(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ShimmerBox(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox.textLine(width: 120, height: 14),
              const SizedBox(height: 12),
              ShimmerBox.textLine(width: 80, height: 12),
              const SizedBox(height: 8),
              ShimmerBox.rectangle(width: double.infinity, height: 8),
              const SizedBox(height: 12),
              ShimmerBox.textLine(width: 100, height: 14),
              const SizedBox(height: 12),
              ShimmerBox.textLine(width: 60, height: 12),
              const SizedBox(height: 8),
              ShimmerBox.rectangle(width: double.infinity, height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetTransactions(BuildContext context, BudgetProgress bp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Budget Transactions',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${bp.budgetAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  // Transaction list
                  Expanded(
                    child: FutureBuilder<List<Record>>(
                      future: di
                          .getIt<GetBudgetTransactions>()(bp.budgetId)
                          .then((r) => r.getOrElse(() => [])),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return BudgetTransactionList(
                          records: snapshot.data ?? [],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBalanceSkeleton() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ShimmerBox(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ShimmerBox.textLine(width: 100, height: 12),
              const SizedBox(height: 8),
              // Value
              ShimmerBox.textLine(width: 160, height: 32),
              const Spacer(),
              // Income/Expense rows
              Row(
                children: [
                  ShimmerBox.rectangle(width: 80, height: 36, borderRadius: 8),
                  const SizedBox(width: 24),
                  ShimmerBox.rectangle(width: 80, height: 36, borderRadius: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tries to resolve [GetBudgetsWithProgress] from the DI container.
  /// Returns `null` if the lazy-registered budget module hasn't been initialized yet.
  /// This prevents a synchronous `getIt` throw from crashing the entire dashboard.
  GetBudgetsWithProgress? _tryGetBudgetsWithProgress() {
    try {
      return di.getIt<GetBudgetsWithProgress>();
    } catch (_) {
      return null;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAuth = authState is Authenticated;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      if (isAuth)
        PopupMenuItem(
          value: 'account',
          child: _MenuRow(
            icon: PhosphorIcons.user(PhosphorIconsStyle.light),
            text: 'Profile',
          ),
        )
      else
        PopupMenuItem(
          value: 'sign_in',
          child: _MenuRow(
            icon: PhosphorIcons.signIn(PhosphorIconsStyle.light),
            text: 'Sign In',
          ),
        ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'settings',
        child: _MenuRow(
          icon: PhosphorIcons.gear(PhosphorIconsStyle.light),
          text: 'Settings',
        ),
      ),
      PopupMenuItem(
        value: 'theme',
        child: _MenuRow(
          icon: isDark
              ? PhosphorIcons.moon(PhosphorIconsStyle.fill)
              : PhosphorIcons.sun(PhosphorIconsStyle.fill),
          text: isDark ? 'Dark Mode' : 'Light Mode',
          trailing: isDark
              ? PhosphorIcons.check(PhosphorIconsStyle.bold)
              : null,
        ),
      ),
      PopupMenuItem(
        value: 'language',
        child: _MenuRow(
          icon: PhosphorIcons.translate(PhosphorIconsStyle.light),
          text: 'Language',
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'feedback',
        child: _MenuRow(
          icon: PhosphorIcons.chatTeardrop(PhosphorIconsStyle.light),
          text: 'Feedback',
        ),
      ),
      if (isAuth) ...[
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'sign_out',
          child: _MenuRow(
            icon: PhosphorIcons.signOut(PhosphorIconsStyle.light),
            text: 'Sign Out',
          ),
        ),
      ],
    ];
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'account':
        Navigator.push(
          context,
          SlidePageRoute(builder: (_) => const SettingsPage()),
        );
      case 'sign_in':
        context.read<AuthBloc>().add(const SignInWithGoogleRequested());
      case 'settings':
        Navigator.push(
          context,
          SlidePageRoute(builder: (_) => const SettingsPage()),
        );
      case 'theme':
        final isDark = Theme.of(context).brightness == Brightness.dark;
        di.getIt<SettingsBloc>().add(UpdateTheme(isDark ? 'light' : 'dark'));
      case 'language':
        Navigator.push(
          context,
          SlidePageRoute(builder: (_) => const SettingsPage()),
        );
      case 'feedback':
        Navigator.push(
          context,
          SlidePageRoute(builder: (_) => const FeedbackPage()),
        );
      case 'sign_out':
        context.read<AuthBloc>().add(const SignOutRequested());
    }
  }
}

// ──────────────────────────────────
// Menu Row
// ──────────────────────────────────
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final IconData? trailing;

  const _MenuRow({required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        if (trailing != null) Icon(trailing, size: 18),
      ],
    );
  }
}

// ──────────────────────────────────
// Feedback Stub Page
// ──────────────────────────────────
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Feedback',
      child: const Center(child: Text('Coming soon')),
    );
  }
}

// ──────────────────────────────────
// Balance Row (income / expense)
// ──────────────────────────────────
class _BalanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final NumberFormat currencyFmt;

  const _BalanceRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.currencyFmt,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: onSurface.withAlpha(140)),
            ),
            Text(
              currencyFmt.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────
// Budget Progress Card (Home View)
// ──────────────────────────────────
class _BudgetProgressCard extends StatelessWidget {
  final BudgetProgress progress;
  final NumberFormat currencyFmt;
  final VoidCallback onTap;

  const _BudgetProgressCard({
    required this.progress,
    required this.currencyFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spent = currencyFmt.format(progress.spentAmount);
    final budget = currencyFmt.format(progress.budgetAmount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Budget name (from categoryId for now)
                  Expanded(
                    child: Text(
                      progress.categoryId ?? 'Overall Budget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  // Spent vs Budget
                  Text(
                    '$spent / $budget',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface.withAlpha(180),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              BudgetProgressIndicator(percentage: progress.percentage),
              const SizedBox(height: 4),
              // Percentage text
              Text(
                '${progress.percentage.toStringAsFixed(0)}% used',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurface.withAlpha(120),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────
// Recent Transaction Tile
// ──────────────────────────────────
class _RecentTile extends StatelessWidget {
  final Record record;
  final NumberFormat fmt;
  const _RecentTile({required this.record, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isExpense = record.recordType == RecordType.expense;
    final amtColor = isExpense ? colors.error : colors.secondary;
    final dateStr = DateFormat('MMM dd').format(record.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: amtColor.withAlpha(25),
            child: Icon(
              isExpense
                  ? PhosphorIcons.trendDown(PhosphorIconsStyle.fill)
                  : PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
              color: amtColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description.isNotEmpty
                      ? record.description
                      : (isExpense ? 'Expense' : 'Income'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          Text(
            fmt.format(record.amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: amtColor,
            ),
          ),
        ],
      ),
    );
  }
}
