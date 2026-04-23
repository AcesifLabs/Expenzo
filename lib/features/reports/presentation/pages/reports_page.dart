import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/date_amount.dart';
import '../../domain/entities/category_amount.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/get_spending_trend.dart';
import '../../domain/usecases/get_category_breakdown.dart';
import '../../domain/usecases/get_spending_insights.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trend'),
            Tab(text: 'Categories'),
            Tab(text: 'Insights'),
          ],
        ),
        actions: [_buildDateRangeSelector(context)],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        buildWhen: (previous, current) =>
            current is ReportsLoaded ||
            current is ReportsError ||
            current is ReportsLoading,
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
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.calendar_today),
      onSelected: (value) {
        final now = DateTime.now();
        DateTime startDate;
        DateTime endDate = now;

        switch (value) {
          case 'week':
            startDate = now.subtract(const Duration(days: 7));
            break;
          case 'month':
            startDate = now.subtract(const Duration(days: 30));
            break;
          case '3months':
            startDate = now.subtract(const Duration(days: 90));
            break;
          case 'year':
            startDate = DateTime(now.year, 1, 1);
            break;
          default:
            startDate = now.subtract(const Duration(days: 30));
        }

        context.read<ReportsBloc>().add(
          LoadReports(
            startDate: startDate,
            endDate: endDate,
            granularity: Granularity.daily,
          ),
        );
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'week', child: Text('Last 7 Days')),
        const PopupMenuItem(value: 'month', child: Text('Last 30 Days')),
        const PopupMenuItem(value: '3months', child: Text('Last 3 Months')),
        const PopupMenuItem(value: 'year', child: Text('This Year')),
      ],
    );
  }

  Widget _buildTrendTab(BuildContext context, ReportsLoaded state) {
    return Column(
      children: [
        _buildGranularitySelector(context, state.granularity),
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

  Widget _buildGranularitySelector(BuildContext context, Granularity current) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SegmentedButton<Granularity>(
        segments: const [
          ButtonSegment(value: Granularity.daily, label: Text('Daily')),
          ButtonSegment(value: Granularity.weekly, label: Text('Weekly')),
          ButtonSegment(value: Granularity.monthly, label: Text('Monthly')),
        ],
        selected: {current},
        onSelectionChanged: (selection) {
          context.read<ReportsBloc>().add(
            ChangeGranularity(granularity: selection.first),
          );
        },
      ),
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
