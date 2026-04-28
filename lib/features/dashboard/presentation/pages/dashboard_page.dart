import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_summary_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_section_header.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import '../../domain/entities/date_range.dart';
import '../../domain/entities/dashboard_summary.dart';
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

        // Time-based greeting
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

        return AppScaffold.slivers(
          title: 'Welcome back, $name',
          subtitle: greeting,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha(30),
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
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
                    color: const Color(0xFF34C759),
                    currencyFmt: currencyFmt,
                  ),
                  const SizedBox(width: 24),
                  _BalanceRow(
                    icon: PhosphorIcons.trendDown(PhosphorIconsStyle.fill),
                    label: 'Expense',
                    amount: s.totalExpense,
                    color: const Color(0xFFFF3B30),
                    currencyFmt: currencyFmt,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Budgets section
        const SliverToBoxAdapter(child: AppSectionHeader(title: 'Budgets')),
        if (s.categoryBreakdown.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppEmptyState(
                  icon: Icons.inbox,
                  message: 'No spending this period',
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: s.categoryBreakdown
                      .take(5)
                      .map((cat) => _CategoryBudgetRow(cat: cat))
                      .toList(),
                ),
              ),
            ),
          ),
        // Recent Activity
        const SliverToBoxAdapter(
          child: AppSectionHeader(title: 'Recent Activity'),
        ),
        if (s.recentTransactions.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppEmptyState(
                  icon: Icons.inbox,
                  message: 'No transactions yet',
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: s.recentTransactions
                      .map((r) => _RecentTile(record: r, fmt: currencyFmt))
                      .toList(),
                ),
              ),
            ),
          ),
      ];
    }

    // DashboardInitial — trigger load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(
        const LoadDashboard(
          dateRange: DateRange(preset: DateRangePreset.thisMonth),
        ),
      );
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

  Widget _buildBalanceSkeleton() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(140),
              ),
            ),
            Text(
              currencyFmt.format(amount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────
// Category Budget Row
// ──────────────────────────────────
class _CategoryBudgetRow extends StatelessWidget {
  final CategoryAmount cat;
  const _CategoryBudgetRow({required this.cat});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(cat.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat.categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                fmt.format(cat.amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: cat.percentage / 100,
              backgroundColor: colors.primary.withAlpha(20),
              color: colors.primary,
              minHeight: 8,
            ),
          ),
        ],
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
    final amtColor = isExpense
        ? const Color(0xFFFF3B30)
        : const Color(0xFF34C759);
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
