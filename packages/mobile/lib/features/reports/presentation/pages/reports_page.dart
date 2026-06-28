import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/di/injection_container.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_state.dart';
import '../widgets/spending_trend_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/insights_card.dart';
import '../widgets/skeletons/chart_skeleton.dart';
import '../widgets/skeletons/pie_chart_skeleton.dart';
import '../widgets/skeletons/insights_skeleton.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReportsBloc>(),
      child: const _ReportsPageContent(),
    );
  }
}

class _ReportsPageContent extends StatefulWidget {
  const _ReportsPageContent();

  @override
  State<_ReportsPageContent> createState() => _ReportsPageContentState();
}

class _ReportsPageContentState extends State<_ReportsPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reports',
      actions: [_buildDateRangeSelector(context)],
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Trend'),
              Tab(text: 'Categories'),
              Tab(text: 'Insights'),
            ],
          ),
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return TabBarView(
                    controller: _tabController,
                    children: const [
                      ChartSkeleton(),
                      PieChartSkeleton(),
                      InsightsSkeleton(),
                    ],
                  );
                }

                if (state is ReportsError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is ReportsLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTrendTab(context, state),
                      _buildCategoriesTab(context, state),
                      _buildInsightsTab(context, state),
                    ],
                  );
                }

                return const Center(child: Text('Load reports to see data'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.calendar_today),
      onSelected: (value) {},
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'week', child: Text('Last 7 Days')),
        const PopupMenuItem(value: 'month', child: Text('Last 30 Days')),
      ],
    );
  }

  Widget _buildTrendTab(BuildContext context, ReportsLoaded state) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SpendingTrendChart(
              data: state.spendingTrend,
              granularity: state.granularity,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(BuildContext context, ReportsLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CategoryPieChart(data: state.categoryBreakdown),
    );
  }

  Widget _buildInsightsTab(BuildContext context, ReportsLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InsightsCard(insights: state.insights),
    );
  }
}
