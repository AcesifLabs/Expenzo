import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/date_range.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_breakdown_widget.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/skeletons/dashboard_skeleton.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCcw),
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _buildDateRangeSelector(context, state),
                  ),
                ),
                ..._buildContentSlivers(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, DashboardState state) {
    final currentPreset = state is DashboardLoaded
        ? state.dateRange.preset
        : DateRangePreset.thisMonth;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: SegmentedButton<DateRangePreset>(
                segments: const [
                  ButtonSegment(
                    value: DateRangePreset.thisMonth,
                    label: Text('This Month'),
                  ),
                  ButtonSegment(
                    value: DateRangePreset.lastMonth,
                    label: Text('Last Month'),
                  ),
                  ButtonSegment(
                    value: DateRangePreset.thisYear,
                    label: Text('This Year'),
                  ),
                ],
                selected: {currentPreset},
                onSelectionChanged: (selection) {
                  context.read<DashboardBloc>().add(
                    ChangeDateRange(preset: selection.first),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(
    BuildContext context,
    DashboardState state,
  ) {
    if (state is DashboardLoading) {
      return [const SliverToBoxAdapter(child: DashboardSkeleton())];
    }

    if (state is DashboardError) {
      return [
        SliverToBoxAdapter(
          child: Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(RefreshDashboard());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    if (state is DashboardLoaded) {
      return [
        SliverToBoxAdapter(
          child: SummaryCard(
            title: 'Total Spent (${state.dateRange.label})',
            amount: state.summary.totalSpent,
            percentChange: state.summary.percentChange,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: CategoryBreakdownWidget(
            categories: state.summary.categoryBreakdown,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: RecentTransactionsList(
            transactions: state.summary.recentTransactions,
          ),
        ),
      ];
    }

    // Initial state - load default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(
        const LoadDashboard(
          dateRange: DateRange(preset: DateRangePreset.thisMonth),
        ),
      );
    });

    return const [SliverToBoxAdapter(child: DashboardSkeleton())];
  }
}
