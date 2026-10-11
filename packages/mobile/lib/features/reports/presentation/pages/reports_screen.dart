import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/di/injection_container.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/nav_bar_metrics.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
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
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Single parent screen for Trend / Categories / Insights.
///
/// Uses a [TabController] to swap content in-place — tab changes
/// never push a new route.
class ReportsScreen extends StatelessWidget {
  /// True when shown as a tab in the app shell: no back button, and the
  /// content stops above the floating navigation bar.
  final bool isTab;

  /// Bumped by the app shell when the Reports tab is shown again, so the
  /// figures include records added in the meantime.
  final ValueListenable<int>? refreshTick;

  const ReportsScreen({super.key, this.isTab = false, this.refreshTick});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportsBloc>(),
      child: _ReportsScreenContent(isTab: isTab, refreshTick: refreshTick),
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

String _rangeLabel(DateTime? start, DateTime? end) {
  if (start != null && end != null && end.difference(start).inDays <= 7) {
    return t.reports.last7Days;
  }

  return t.reports.last30Days;
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
    items: [
      PopupMenuItem(value: 'week', child: Text(t.reports.last7Days)),
      PopupMenuItem(value: 'month', child: Text(t.reports.last30Days)),
    ],
  ).then((value) {
    if (value != null && context.mounted) {
      _handleReportsDateRangeSelected(context, value);
    }
  });
}

Widget _buildReportsTrendContent(
  AppPalette palette,
  ReportsLoaded state,
  double reportsContentInnerInset,
) {
  final wholeNumberFmt = CurrencyFormatter.getFormatter(decimalDigits: 0);
  final decimalFmt = CurrencyFormatter.getFormatter(decimalDigits: 2);
  final metrics = t.reports.metrics;

  final start = DateFormat('MMM d').format(state.startDate);
  final end = DateFormat('MMM d').format(state.endDate);
  final total = state.insights.totalSpent;
  final compareText = total == 0
      ? t.reports.noSpending
      : t.reports.totalSpentInPeriod(amount: wholeNumberFmt.format(total));

  return SingleChildScrollView(
    padding: EdgeInsets.only(
      top: AppSpacing.lg,
      left: reportsContentInnerInset,
      right: reportsContentInnerInset,
      // Room for the AI button floating over the bottom of the list.
      bottom: 96,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$start – $end',
          style: AppTypography.bodyMedium.copyWith(
            color: palette.textSecondary,
          ),
        ),
        TrendBarChart(data: state.spendingTrend),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: [
            MetricBox(
              value: wholeNumberFmt.format(state.insights.totalSpent),
              label: metrics.totalSpent,
              valueColor: palette.expense,
            ),
            const SizedBox(height: AppSpacing.smd),
            MetricBox(
              value: decimalFmt.format(state.insights.avgDailySpending),
              label: metrics.dailyAverage,
              valueColor: palette.textPrimary,
            ),
            const SizedBox(height: AppSpacing.smd),
            MetricBox(
              value: wholeNumberFmt.format(state.insights.highestDayAmount),
              label: metrics.highestDay,
              valueColor: palette.accent,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          compareText,
          style: AppTypography.bodyMedium.copyWith(color: palette.expense),
        ),
      ],
    ),
  );
}

Widget _buildReportsCategoriesContent(
  AppPalette palette,
  ReportsLoaded state,
  double reportsContentInnerInset,
) {
  return SingleChildScrollView(
    padding: EdgeInsets.only(
      top: AppSpacing.lg,
      left: reportsContentInnerInset,
      right: reportsContentInnerInset,
      // Room for the AI button floating over the bottom of the list.
      bottom: 96,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.reports.spendingByCategory,
                  style: AppTypography.titleMedium.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
  AppPalette palette,
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
        failureText(failure),
        style: TextStyle(color: palette.expense),
      ),
    ),
    (items) => ListView(
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: reportsContentInnerInset,
        right: reportsContentInnerInset,
        bottom: 96,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            t.reports.observations,
            style: AppTypography.bodyMedium.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.smd),
            child: InsightCard(item: item),
          ),
        ),
      ],
    ),
  );
}

Widget _buildReportsTabContent(
  AppPalette palette,
  ReportsLoaded state,
  TabController controller,
  double reportsContentInnerInset,
) {
  return TabBarView(
    controller: controller,
    children: [
      _buildReportsTrendContent(palette, state, reportsContentInnerInset),
      _buildReportsCategoriesContent(palette, state, reportsContentInnerInset),
      _buildReportsInsightsContent(palette, state, reportsContentInnerInset),
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
  final bool isTab;

  const _ReportsBodyArgs({
    required this.context,
    required this.state,
    required this.controller,
    required this.reportsSideInset,
    required this.reportsContentInnerInset,
    required this.isTab,
  });
}

Widget _buildReportsStateContent(
  ReportsState state,
  AppPalette palette,
  _ReportsBodyArgs args,
) {
  if (state is ReportsLoaded) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: args.reportsSideInset),
        child: _buildReportsTabContent(
          palette,
          state,
          args.controller,
          args.reportsContentInnerInset,
        ),
      ),
    );
  }
  if (state is ReportsLoading) {
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }
  if (state is ReportsError) {
    return Expanded(
      child: Center(
        child: Text(state.message, style: TextStyle(color: palette.expense)),
      ),
    );
  }

  return Expanded(
    child: Center(
      child: Text(
        t.reports.noData,
        style: TextStyle(color: palette.textSecondary),
      ),
    ),
  );
}

Widget _buildReportsBody({required _ReportsBodyArgs args}) {
  final state = args.state;
  final palette = args.context.palette;

  final rangeLabel = state is ReportsLoaded
      ? _rangeLabel(state.startDate, state.endDate)
      : _rangeLabel(null, null);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ReportsTopBar(
        title: t.reports.title,
        rangeLabel: rangeLabel,
        showBackButton: !args.isTab,
        onCalendar: _showReportsDateRangeMenu,
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: args.reportsSideInset,
                ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: args.reportsSideInset,
                ),
                child: Container(height: 1, color: palette.divider),
              ),
              _buildReportsStateContent(state, palette, args),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ReportsScreenContent extends StatefulWidget {
  final bool isTab;
  final ValueListenable<int>? refreshTick;

  const _ReportsScreenContent({required this.isTab, this.refreshTick});

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
    widget.refreshTick?.addListener(_onRefreshTick);
  }

  void _onRefreshTick() =>
      context.read<ReportsBloc>().add(const RefreshReports());

  @override
  void dispose() {
    widget.refreshTick?.removeListener(_onRefreshTick);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.bg,
      body: Padding(
        padding: EdgeInsets.only(
          bottom: widget.isTab ? NavBarMetrics.clearance(context) : 0,
        ),
        child: SafeArea(
          bottom: !widget.isTab,
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
                    isTab: widget.isTab,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: AIChatFAB(
                  onPressed: () => context.push('/ai-assistant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
