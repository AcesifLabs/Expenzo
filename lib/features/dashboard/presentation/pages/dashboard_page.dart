import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/date_range.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_breakdown_widget.dart';
import '../widgets/recent_transactions_list.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDateRangeSelector(context, state),
                  const SizedBox(height: 16),
                  _buildContent(context, state),
                ],
              ),
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

  Widget _buildContent(BuildContext context, DashboardState state) {
    if (state is DashboardLoading) {
      return Column(
        children: [
          SummaryCard(title: 'Total Spent', amount: 0, isLoading: true),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state is DashboardError) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
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
      );
    }

    if (state is DashboardLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SummaryCard(
            title: 'Total Spent (${state.dateRange.label})',
            amount: state.summary.totalSpent,
            percentChange: state.summary.percentChange,
          ),
          const SizedBox(height: 16),
          CategoryBreakdownWidget(categories: state.summary.categoryBreakdown),
          const SizedBox(height: 16),
          RecentTransactionsList(
            transactions: state.summary.recentTransactions,
          ),
        ],
      );
    }

    // Initial state - load default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(
        const LoadDashboard(
          dateRange: DateRange(preset: DateRangePreset.thisMonth),
        ),
      );
    });

    return const Center(child: Text('Loading dashboard...'));
  }
}
