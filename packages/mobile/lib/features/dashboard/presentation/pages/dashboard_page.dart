import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/dashboard/presentation/models/dashboard_budget_preview.dart';
import 'package:expense_tracker/features/dashboard/presentation/models/dashboard_supplementary_data.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/balance_row.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_trend_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/menu_row.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/reports/domain/entities/date_amount.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_trend.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import '../../domain/entities/date_range.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const DashboardPage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.getIt<DashboardBloc>()),
        BlocProvider(create: (_) => di.getIt<AuthBloc>()),
      ],
      child: DashboardView(onNavigateToTab: onNavigateToTab),
    );
  }
}

class DashboardView extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const DashboardView({super.key, this.onNavigateToTab});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const _horizontalPadding = 24.0;

  bool _initialLoadScheduled = false;
  Future<DashboardSupplementaryData>? _supplementaryFuture;
  Future<List<DateAmount>>? _trendFuture;
  DateRange? _secondaryDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialLoadScheduled) return;
      _initialLoadScheduled = true;
      context.read<DashboardBloc>().add(
        const LoadDashboard(
          dateRange: DateRange(preset: DateRangePreset.thisMonth),
        ),
      );
    });
  }

  void _syncSecondaryDateRange(DateRange? nextRange) {
    if (nextRange == null) return;
    if (_secondaryDateRange == nextRange) return;
    _secondaryDateRange = nextRange;
    _supplementaryFuture = null;
    _trendFuture = null;
  }

  Future<DashboardSupplementaryData> _loadSupplementaryData() async {
    await di.featureDependenciesReady;
    final getBudgetsWithProgress = _tryGetBudgetsWithProgress();
    final getCategories = _tryGetCategories();

    if (getBudgetsWithProgress == null || getCategories == null) {
      return DashboardSupplementaryData.empty;
    }

    final categoryResult = await getCategories(const GetCategoriesParams());
    final budgetResult = await getBudgetsWithProgress(limit: 5);

    final categories = categoryResult.fold(
      (_) => <Category>[],
      (value) => value,
    );
    final categoriesById = {
      for (final category in categories) ?category.id: category,
    };
    final budgets = budgetResult.fold((failure) {
      debugPrint('DashboardPage: Failed to load budgets: ${failure.message}');

      return <BudgetProgress>[];
    }, (value) => value);

    final previews = budgets
        .map(
          (progress) => DashboardBudgetPreview(
            progress: progress,
            title: _resolveBudgetTitle(progress, categoriesById),
            emoji: progress.categoryId == null
                ? null
                : categoriesById[progress.categoryId]?.emoji,
          ),
        )
        .toList();

    return DashboardSupplementaryData(
      budgetPreviews: previews,
      categoriesById: categoriesById,
    );
  }

  Future<List<DateAmount>> _loadTrend(DateRange dateRange) async {
    await di.featureDependenciesReady;
    final getSpendingTrend = _tryGetSpendingTrend();

    if (getSpendingTrend == null) return [];

    final result = await getSpendingTrend(
      startDate: dateRange.startDate,
      endDate: dateRange.endDate,
      granularity: Granularity.daily,
    );

    return result.fold((failure) {
      debugPrint('DashboardPage: Failed to load trend: ${failure.message}');

      return <DateAmount>[];
    }, (trend) => trend);
  }

  void _ensureSupplementaryFuture() {
    _supplementaryFuture ??= _loadSupplementaryData();
  }

  void _ensureTrendFuture(DateRange dateRange) {
    _trendFuture ??= _loadTrend(dateRange);
  }

  void _invalidateSecondaryFutures() {
    _supplementaryFuture = null;
    _trendFuture = null;
  }

  Future<void> _onRefresh() {
    _invalidateSecondaryFutures();
    context.read<DashboardBloc>().add(RefreshDashboard());

    return Future<void>.value();
  }

  String _resolveBudgetTitle(
    BudgetProgress progress,
    Map<String, Category> categoriesById,
  ) {
    final categoryId = progress.categoryId;
    if (categoryId == null) return 'Overall Budget';

    return categoriesById[categoryId]?.name ?? 'Budget';
  }

  String _displayName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'User';

    return parts.first;
  }

  Widget _buildAvatarWidget(
    BuildContext context,
    AuthState authState,
    String name,
    String? photoUrl,
  ) {
    final colors = Theme.of(context).colorScheme;
    final Widget? avatarChild;

    if (photoUrl != null) {
      avatarChild = null;
    } else if (authState is Authenticated) {
      avatarChild = Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.onPrimary,
        ),
      );
    } else {
      avatarChild = Icon(PiconsRegular.user, color: colors.onPrimary, size: 20);
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primary,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: avatarChild,
          ),
          if (authState is AuthLoading)
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthState authState,
    String displayName,
    String? photoUrl,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        24,
        _horizontalPadding,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $displayName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => _buildMenuItems(context),
            padding: EdgeInsets.zero,
            icon: _buildAvatarWidget(context, authState, displayName, photoUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, DashboardLoaded state) {
    final colors = Theme.of(context).colorScheme;
    final currencyFmt = CurrencyFormatter.getFormatter(decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        8,
        _horizontalPadding,
        0,
      ),
      child: AppCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withAlpha(170),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFmt.format(state.summary.totalBalance),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BalanceRow(
                    icon: PiconsFill.trendUp,
                    label: 'Income',
                    amount: state.summary.totalIncome,
                    color: colors.secondary,
                    currencyFmt: currencyFmt,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: BalanceRow(
                    icon: PiconsFill.trendDown,
                    label: 'Expense',
                    amount: state.summary.totalExpense,
                    color: colors.error,
                    currencyFmt: currencyFmt,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoadingContent(BuildContext context, DateRange dateRange) {
    _ensureSupplementaryFuture();
    _ensureTrendFuture(dateRange);

    return [
      SliverToBoxAdapter(child: _buildBalanceSkeleton(context)),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: 'Budgets',
            onTrailingTap: () => widget.onNavigateToTab?.call(3),
          ),
        ),
      ),
      SliverToBoxAdapter(child: _buildBudgetSkeleton(context)),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: 'Recent Activity',
            onTrailingTap: () => widget.onNavigateToTab?.call(1),
          ),
        ),
      ),
      SliverToBoxAdapter(child: _buildRecentActivitySkeleton(context)),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: 'Spending Patterns',
            onTrailingTap: () => context.push('/reports'),
          ),
        ),
      ),
      SliverToBoxAdapter(child: _buildTrendSkeleton(context)),
    ];
  }

  List<Widget> _buildErrorContent(BuildContext context, DashboardError state) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(_horizontalPadding),
          child: Center(
            child: AppCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PiconsLight.warningCircle,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardBloc>().add(RefreshDashboard()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildLoadedContent(
    BuildContext context,
    DashboardLoaded state,
  ) {
    return [
      SliverToBoxAdapter(child: _buildBalanceCard(context, state)),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: 'Budgets',
            onTrailingTap: () => widget.onNavigateToTab?.call(3),
          ),
        ),
      ),
      _buildBudgetsSection(),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: 'Recent Activity',
            onTrailingTap: () => widget.onNavigateToTab?.call(1),
          ),
        ),
      ),
      _buildRecentTransactionsSection(state.summary.recentTransactions),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: 'Spending Patterns',
            onTrailingTap: () => context.push('/reports'),
          ),
        ),
      ),
      _buildTrendSection(context, state),
    ];
  }

  Widget _buildBudgetsSection() {
    final currencyFmt = CurrencyFormatter.getFormatter(decimalDigits: 0);
    _ensureSupplementaryFuture();

    return SliverToBoxAdapter(
      child: FutureBuilder<DashboardSupplementaryData>(
        future: _supplementaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildBudgetSkeleton(context);
          }

          final data = snapshot.data ?? DashboardSupplementaryData.empty;
          if (data.budgetPreviews.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: AppCard(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: AppEmptyState(
                  icon: PiconsRegular.tray,
                  message: 'No budgets set',
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: AppCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var i = 0; i < data.budgetPreviews.length; i++) ...[
                    _BudgetPreviewTile(
                      preview: data.budgetPreviews[i],
                      currencyFmt: currencyFmt,
                      onTap: () => _showBudgetTransactions(
                        context,
                        data.budgetPreviews[i].progress,
                      ),
                    ),
                    if (i != data.budgetPreviews.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactionsSection(List<Record> transactions) {
    final currencyFmt = CurrencyFormatter.getFormatter(decimalDigits: 2);
    _ensureSupplementaryFuture();

    return SliverToBoxAdapter(
      child: FutureBuilder<DashboardSupplementaryData>(
        future: _supplementaryFuture,
        builder: (context, snapshot) {
          final categoriesById =
              snapshot.data?.categoriesById ?? const <String, Category>{};

          if (transactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: AppCard(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: AppEmptyState(
                  icon: PiconsRegular.tray,
                  message: 'No transactions yet',
                ),
              ),
            );
          }

          final recentTwo = transactions.take(2).toList();
          final dividerColor = Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha(16);

          final children = <Widget>[];
          for (var i = 0; i < recentTwo.length; i++) {
            final record = recentTwo[i];
            final categoryName = record.categoryId == null
                ? record.recordType.displayName
                : categoriesById[record.categoryId]?.name;
            children.add(
              _RecentTile(
                record: record,
                fmt: currencyFmt,
                categoryName: categoryName,
              ),
            );
            if (i < recentTwo.length - 1) {
              children.add(Divider(height: 1, color: dividerColor));
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: AppCard(
              borderRadius: 16,
              clipBehavior: Clip.antiAlias,
              child: Column(children: children),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendSection(BuildContext context, DashboardLoaded state) {
    final dateRange = state.dateRange;
    if (dateRange == null) {
      return SliverToBoxAdapter(child: _buildTrendSkeleton(context));
    }

    _ensureTrendFuture(dateRange);

    return SliverToBoxAdapter(
      child: FutureBuilder<List<DateAmount>>(
        future: _trendFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildTrendSkeleton(context);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: DashboardTrendCard(
              title: dateRange.label,
              totalSpent: state.summary.totalSpent,
              percentChange: state.summary.percentChange,
              trend: snapshot.data ?? const [],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ShimmerBox(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: List.generate(2, _buildSkeletonBudgetRow)),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonBudgetRow(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: index == 1 ? 0 : 20),
      child: Column(
        children: [
          Row(
            children: [
              ShimmerBox.circle(size: 20),
              const SizedBox(width: 8),
              Expanded(child: ShimmerBox.textLine(width: 120, height: 14)),
              const SizedBox(width: 8),
              ShimmerBox.textLine(width: 90, height: 12),
            ],
          ),
          const SizedBox(height: 12),
          ShimmerBox.rectangle(width: double.infinity, height: 12),
        ],
      ),
    );
  }

  Widget _buildBalanceSkeleton(BuildContext context) {
    final shimmerTextLine = ShimmerBox.textLine(width: 120, height: 36);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ShimmerBox(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox.textLine(width: 96, height: 12),
                const SizedBox(height: 8),
                ShimmerBox.textLine(width: 180, height: 32),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: shimmerTextLine),
                    const SizedBox(width: 24),
                    Expanded(child: shimmerTextLine),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ShimmerBox(
          child: Column(
            children: const [
              _RecentActivityTileSkeleton(),
              Divider(height: 1),
              _RecentActivityTileSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ShimmerBox(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.textLine(width: 96, height: 14),
                    ShimmerBox.textLine(width: 100, height: 14),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(14, _buildSkeletonTrendBar),
                  ),
                ),
                const SizedBox(height: 8),
                ShimmerBox.textLine(width: 120, height: 12),
              ],
            ),
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
      builder: (_) => _buildBudgetTransactionSheet(bp),
    );
  }

  Widget _buildSkeletonTrendBar(int index) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: index == 13 ? 0 : 3),
        child: ShimmerBox.rectangle(
          width: double.infinity,
          height: 12 + (index % 5) * 6,
        ),
      ),
    );
  }

  Widget _buildBudgetTransactionSheet(BudgetProgress bp) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, _) {
          return Column(
            children: [
              _buildSheetHandle(context),
              _buildSheetHeader(context, bp),
              const Divider(height: 24),
              _buildTransactionList(bp),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSheetHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context, BudgetProgress bp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            'Budget Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            CurrencyFormatter.getFormatter(
              decimalDigits: 0,
            ).format(bp.budgetAmount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BudgetProgress bp) {
    return Expanded(
      child: FutureBuilder<List<Record>>(
        future: di.getIt<GetBudgetTransactions>()(bp.budgetId).then(
          (result) => result.getOrElse(() => []),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return BudgetTransactionList(records: snapshot.data ?? []);
        },
      ),
    );
  }

  GetBudgetsWithProgress? _tryGetBudgetsWithProgress() {
    try {
      return di.getIt<GetBudgetsWithProgress>();
    } catch (e, s) {
      debugPrint('Dashboard budgets error: $e\n$s');

      return null;
    }
  }

  GetCategories? _tryGetCategories() {
    try {
      return di.getIt<GetCategories>();
    } catch (e, s) {
      debugPrint('Dashboard categories error: $e\n$s');

      return null;
    }
  }

  GetSpendingTrend? _tryGetSpendingTrend() {
    try {
      return di.getIt<GetSpendingTrend>();
    } catch (e, s) {
      debugPrint('Dashboard trend error: $e\n$s');

      return null;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAuth = authState is Authenticated;
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return [
      if (isAuth)
        PopupMenuItem(
          value: 'account',
          child: MenuRow(icon: PiconsLight.user, text: 'Profile'),
        )
      else
        PopupMenuItem(
          value: 'sign_in',
          child: MenuRow(icon: PiconsLight.signIn, text: 'Sign In'),
        ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'settings',
        child: MenuRow(icon: PiconsLight.gear, text: 'Settings'),
      ),
      PopupMenuItem(
        value: 'theme',
        child: MenuRow(
          icon: isDark ? PiconsFill.moon : PiconsFill.sun,
          text: isDark ? 'Dark Mode' : 'Light Mode',
          trailing: isDark ? PiconsBold.check : null,
        ),
      ),
      PopupMenuItem(
        value: 'language',
        child: MenuRow(icon: PiconsLight.translate, text: 'Language'),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'feedback',
        child: MenuRow(icon: PiconsLight.chatTeardrop, text: 'Feedback'),
      ),
      if (isAuth) ...[
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'sign_out',
          child: MenuRow(icon: PiconsLight.signOut, text: 'Sign Out'),
        ),
      ],
    ];
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'account':
      case 'settings':
      case 'language':
        context.push('/settings');
      case 'sign_in':
        context.push('/login');
      case 'theme':
        final isDark =
            Theme.of(context).colorScheme.brightness == Brightness.dark;
        di.getIt<SettingsBloc>().add(UpdateTheme(isDark ? 'light' : 'dark'));
      case 'feedback':
        context.push('/feedback');
      case 'sign_out':
        context.read<AuthBloc>().add(const SignOutRequested());
    }
  }

  List<Widget> _buildContent(
    BuildContext context,
    DashboardState state,
    DateRange dateRange,
  ) {
    return switch (state) {
      DashboardLoading() => _buildLoadingContent(context, dateRange),
      DashboardError() => _buildErrorContent(context, state),
      DashboardLoaded() => _buildLoadedContent(context, state),
      _ => _buildLoadingContent(context, dateRange),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final rawName = authState is Authenticated
            ? (authState.user.displayName ?? 'User')
            : 'User';
        final displayName = _displayName(rawName);
        final photoUrl = authState is Authenticated
            ? authState.user.photoUrl
            : null;

        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final dateRange = state.dateRange ?? DateRange.thisMonth();
            _syncSecondaryDateRange(dateRange);

            return SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(
                        context,
                        authState,
                        displayName,
                        photoUrl,
                      ),
                    ),
                    ..._buildContent(context, state, dateRange),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BudgetPreviewTile extends StatelessWidget {
  final DashboardBudgetPreview preview;
  final NumberFormat currencyFmt;
  final VoidCallback onTap;

  const _BudgetPreviewTile({
    required this.preview,
    required this.currencyFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (preview.emoji != null) ...[
                  Text(
                    preview.emoji ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    preview.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${currencyFmt.format(preview.progress.spentAmount)} of ${currencyFmt.format(preview.progress.budgetAmount)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withAlpha(170),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BudgetProgressIndicator(
                percentage: preview.progress.percentage,
                height: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  static final _timeFormat = DateFormat('h:mm a');
  static final _dayFormat = DateFormat('MMM d');

  final Record record;
  final NumberFormat fmt;
  final String? categoryName;

  const _RecentTile({
    required this.record,
    required this.fmt,
    this.categoryName,
  });

  String _timeLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(record.date.year, record.date.month, record.date.day);
    final difference = today.difference(date).inDays;

    if (difference == 0) return _timeFormat.format(record.date);
    if (difference == 1) return 'Yesterday';

    return _dayFormat.format(record.date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isExpense = record.recordType == RecordType.expense;
    final amountColor = isExpense ? colors.error : colors.secondary;
    final mutedColor = colors.onSurface.withAlpha(140);
    final displayName = record.recordType.displayName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? PiconsRegular.receipt : PiconsRegular.wallet,
              size: 20,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description.isEmpty ? displayName : record.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categoryName ?? displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'}${fmt.format(record.amount.abs())}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _timeLabel(),
                style: TextStyle(fontSize: 12, color: mutedColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivityTileSkeleton extends StatelessWidget {
  const _RecentActivityTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShimmerBox.circle(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox.textLine(height: 14),
                const SizedBox(height: 4),
                ShimmerBox.textLine(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox.textLine(width: 60, height: 16),
              const SizedBox(height: 4),
              ShimmerBox.textLine(width: 48, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
