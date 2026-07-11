import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/di/injection_container.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widgets/reports_top_bar.dart';
import '../widgets/reports_tab_bar.dart';
import '../widgets/trend_bar_chart.dart';
import '../widgets/metric_box.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/category_legend.dart';
import '../widgets/insight_card.dart';
import '../widgets/ai_chat_fab.dart';
import '../../domain/usecases/get_insights.dart';

/// Single parent screen for Trend / Categories / Insights.
///
/// Uses a [TabController] to swap content in-place — tab changes
/// never push a new route.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportsBloc>(),
      child: const _ReportsScreenContent(),
    );
  }
}

void _handleReportsDateRangeSelected(BuildContext context, String value) {
  final now = DateTime.now();
  DateTime startDate;
  DateTime endDate = now;

  switch (value) {
    case 'week':
      startDate = now.subtract(const Duration(days: 7));
    case 'month':
      startDate = now.subtract(const Duration(days: 30));
    default:
      return;
  }

  context.read<ReportsBloc>().add(
    ChangeDateRange(startDate: startDate, endDate: endDate),
  );
}

void _showReportsDateRangeMenu(BuildContext context) {
  final button = context.findRenderObject();
  if (button is! RenderBox) return;

  final overlay = Overlay.of(context).context.findRenderObject();
  if (overlay is! RenderBox) return;

  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(
        button.size.topRight(Offset.zero),
        ancestor: overlay,
      ),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<String>(
    context: context,
    position: position,
    items: const [
      PopupMenuItem(value: 'week', child: Text('Last 7 Days')),
      PopupMenuItem(value: 'month', child: Text('Last 30 Days')),
    ],
  ).then((value) {
    if (value != null && context.mounted) {
      _handleReportsDateRangeSelected(context, value);
    }
  });
}

Widget _buildReportsTrendContent(
  ReportsLoaded state,
  double reportsContentInnerInset,
) {
  final wholeNumberFmt = CurrencyFormatter.getFormatter(decimalDigits: 0);
  final decimalFmt = CurrencyFormatter.getFormatter(decimalDigits: 2);

  final start = DateFormat('MMM d').format(state.startDate);
  final end = DateFormat('MMM d').format(state.endDate);
  final total = state.insights.totalSpent;
  final compareText = total == 0
      ? 'No spending data yet'
      : 'Total spent: ${wholeNumberFmt.format(total)} in this period';

  return SingleChildScrollView(
    padding: EdgeInsets.only(
      top: 20,
      left: reportsContentInnerInset,
      right: reportsContentInnerInset,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$start – $end',
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 13,
            color: Color(0xFF8E8E93),
          ),
        ),
        TrendBarChart(data: state.spendingTrend),
        const SizedBox(height: 16),
        Column(
          children: [
            MetricBox(
              value: wholeNumberFmt.format(state.insights.totalSpent),
              label: 'Total Spent',
              valueColor: const Color(0xFFF48FB1),
            ),
            const SizedBox(height: 12),
            MetricBox(
              value: decimalFmt.format(state.insights.avgDailySpending),
              label: 'Avg Daily',
              valueColor: const Color(0xFFF5F7FA),
            ),
            const SizedBox(height: 12),
            MetricBox(
              value: wholeNumberFmt.format(state.insights.highestDayAmount),
              label: 'Highest Day',
              valueColor: const Color(0xFFD1C4E9),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          compareText,
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 13,
            color: Color(0xFFF48FB1),
          ),
        ),
      ],
    ),
  );
}

Widget _buildReportsCategoriesContent(
  ReportsLoaded state,
  double reportsContentInnerInset,
) {
  return SingleChildScrollView(
    padding: EdgeInsets.only(
      top: 20,
      left: reportsContentInnerInset,
      right: reportsContentInnerInset,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1B1D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Spending by Category',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF5F7FA),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CategoryDonutChart(data: state.categoryBreakdown),
            ],
          ),
        ),
        CategoryLegend(data: state.categoryBreakdown),
      ],
    ),
  );
}

Widget _buildReportsInsightsContent(
  ReportsLoaded state,
  double reportsContentInnerInset,
) {
  final getInsights = getIt<GetInsights>();
  final result = getInsights(
    insights: state.insights,
    spendingTrend: state.spendingTrend,
    categoryBreakdown: state.categoryBreakdown,
  );

  return result.fold(
    (failure) => Center(
      child: Text(
        failure.message,
        style: const TextStyle(color: Color(0xFFF48FB1)),
      ),
    ),
    (items) => ListView(
      padding: EdgeInsets.only(
        top: 20,
        left: reportsContentInnerInset,
        right: reportsContentInnerInset,
      ),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Key observations from your spending this month',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 14,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InsightCard(item: item),
          ),
        ),
      ],
    ),
  );
}

Widget _buildReportsTabContent(
  ReportsLoaded state,
  TabController controller,
  double reportsContentInnerInset,
) {
  return TabBarView(
    controller: controller,
    children: [
      _buildReportsTrendContent(state, reportsContentInnerInset),
      _buildReportsCategoriesContent(state, reportsContentInnerInset),
      _buildReportsInsightsContent(state, reportsContentInnerInset),
    ],
  );
}

void _handleReportsTabSelection(
  TabController controller,
  List<String> tabs,
  String tab,
) {
  final index = tabs.indexOf(tab);
  if (index >= 0) {
    controller.animateTo(index);
  }
}

class _ReportsBodyArgs {
  final BuildContext context;
  final ReportsState state;
  final TabController controller;
  final double reportsSideInset;
  final double reportsContentInnerInset;

  const _ReportsBodyArgs({
    required this.context,
    required this.state,
    required this.controller,
    required this.reportsSideInset,
    required this.reportsContentInnerInset,
  });
}

Widget _buildReportsBody({required _ReportsBodyArgs args}) {
  final state = args.state;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportsTopBar(
          title: 'Reports',
          onCalendar: () => _showReportsDateRangeMenu(args.context),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: args.reportsSideInset),
          child: ReportsTabBar(
            controller: args.controller,
            onTabChanged: (tab) => _handleReportsTabSelection(
              args.controller,
              _ReportsScreenContentState._tabs,
              tab,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: args.reportsSideInset),
          child: Container(height: 1, color: const Color(0x208E8E93)),
        ),
        if (state is ReportsLoaded)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: args.reportsSideInset),
              child: _buildReportsTabContent(
                state,
                args.controller,
                args.reportsContentInnerInset,
              ),
            ),
          )
        else if (state is ReportsLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (state is ReportsError)
          Expanded(
            child: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Color(0xFFF48FB1)),
              ),
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text(
                'No data',
                style: TextStyle(color: Color(0xFF8E8E93)),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ReportsScreenContent extends StatefulWidget {
  const _ReportsScreenContent();

  @override
  State<_ReportsScreenContent> createState() => _ReportsScreenContentState();
}

class _ReportsScreenContentState extends State<_ReportsScreenContent>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['Trend', 'Categories', 'Insights'];
  static const _reportsSideInset = 6.0;
  static const _reportsContentInnerInset = 4.0;

  TabController? _tabController;

  TabController get _controller {
    final controller = _tabController;
    if (controller == null) {
      throw StateError('TabController is not initialized');
    }

    return controller;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141315),
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) => _buildReportsBody(
                args: _ReportsBodyArgs(
                  context: context,
                  state: state,
                  controller: _controller,
                  reportsSideInset: _reportsSideInset,
                  reportsContentInnerInset: _reportsContentInnerInset,
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: AIChatFAB(onPressed: () => context.push('/ai-assistant')),
            ),
          ],
        ),
      ),
    );
  }
}
