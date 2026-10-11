import 'dart:async';

import 'package:flutter/foundation.dart';
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

import 'package:expense_tracker/features/dashboard/presentation/models/dashboard_budget_preview.dart';
import 'package:expense_tracker/features/dashboard/presentation/models/dashboard_supplementary_data.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/balance_row.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_trend_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/menu_row.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/receipt_scan_banner.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/reports/domain/entities/date_amount.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_trend.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/auto_import_prompt_card.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart'
    as cat;
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import '../../domain/entities/date_range.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/categories/presentation/helpers/category_display_name.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_display_name.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<AppRootTab>? onNavigateToTab;
  final ValueListenable<int>? refreshTick;

  const DashboardPage({super.key, this.onNavigateToTab, this.refreshTick});

  @override
  Widget build(BuildContext context) {
    // AuthBloc comes from ExpenzoApp so sign-in state is shared app-wide.
    return BlocProvider(
      create: (_) => di.getIt<DashboardBloc>(),
      child: DashboardView(
        onNavigateToTab: onNavigateToTab,
        refreshTick: refreshTick,
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  final ValueChanged<AppRootTab>? onNavigateToTab;
  final ValueListenable<int>? refreshTick;

  const DashboardView({super.key, this.onNavigateToTab, this.refreshTick});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const _horizontalPadding = 24.0;

  bool _initialLoadScheduled = false;
  Future<DashboardSupplementaryData>? _supplementaryFuture;
  Future<List<DateAmount>>? _trendFuture;
  DateRange? _secondaryDateRange;
  // Disables the scan banner while its sheet is open; a notifier so only the
  // banner rebuilds.
  final _scanOpening = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.refreshTick?.addListener(_onExternalRefresh);
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

  void _onExternalRefresh() {
    if (!mounted) return;
    unawaited(_onRefresh());
  }

  Future<void> _addRecord() async {
    if (await showTransactionSheet(context)) _onExternalRefresh();
  }

  void _onScanTapped() => unawaited(_scanReceipt());

  Future<void> _scanReceipt() async {
    _scanOpening.value = true;
    try {
      if (await showTransactionSheet(context, startWithReceiptScan: true)) {
        _onExternalRefresh();
      }
    } finally {
      if (mounted) _scanOpening.value = false;
    }
  }

  Future<void> _editRecord(Record record) async {
    if (await showTransactionSheet(context, record: record)) {
      _onExternalRefresh();
    }
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

    return DashboardSupplementaryData(
      budgetPreviews: await _loadBudgetPreviews(),
      categoriesById: await _loadCategoriesById(),
    );
  }

  Future<List<DashboardBudgetPreview>> _loadBudgetPreviews() async {
    final getBudgetsWithProgress = _tryGetBudgetsWithProgress();
    if (getBudgetsWithProgress == null) return const [];

    final budgetResult = await getBudgetsWithProgress(limit: 5);
    final budgets = budgetResult.fold((failure) {
      debugPrint('DashboardPage: Failed to load budgets: ${failure.message}');

      return <BudgetProgress>[];
    }, (value) => value);

    return budgets
        .map(
          (progress) => DashboardBudgetPreview(
            progress: progress,
            title: budgetDisplayName(progress.name),
          ),
        )
        .toList();
  }

  /// Lets the recent activity rows show each record's category tile and name.
  Future<Map<String, cat.Category>> _loadCategoriesById() async {
    if (!di.getIt.isRegistered<GetCategories>()) return const {};
    final result = await di.getIt<GetCategories>()(const GetCategoriesParams());

    return result.fold(
      (_) => const {},
      (categories) => {
        for (final category in categories) ?category.id: category,
      },
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

  /// The first name, or null when signed out or the account has no name.
  String? _firstName(AuthState authState) {
    if (authState is! Authenticated) return null;
    final first = (authState.user.displayName ?? '').trim().split(' ').first;

    return first.isEmpty ? null : first;
  }

  /// "Hi, Sam" when we know the name, otherwise today's date.
  String _greeting(String? firstName) => firstName == null
      ? DateFormat('EEEE, d MMMM').format(DateTime.now())
      : t.dashboard.greeting(name: firstName);

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
        style: AppTypography.titleMedium.copyWith(color: colors.onPrimary),
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
    BuildContext context, {
    required String greeting,
    required Widget avatar,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        AppSpacing.lg,
        _horizontalPadding,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _scanOpening,
                  builder: (_, opening, _) =>
                      ReceiptScanBanner(onTap: opening ? null : _onScanTapped),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            ),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => _buildMenuItems(context),
            padding: EdgeInsets.zero,
            icon: avatar,
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
        AppSpacing.sm,
        _horizontalPadding,
        0,
      ),
      child: AppCard(
        borderRadius: AppSpacing.radiusCard,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (state.dateRange ?? DateRange.thisMonth()).netLabel,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurface.withAlpha(170),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              CurrencyFormatter.formatSigned(state.summary.net),
              style: AppTypography.headlineLarge.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: BalanceRow(
                    icon: PiconsRegular.trendUp,
                    label: t.dashboard.income,
                    amount: state.summary.totalIncome,
                    color: context.palette.income,
                    currencyFmt: currencyFmt,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: BalanceRow(
                    icon: PiconsRegular.trendDown,
                    label: t.dashboard.expense,
                    amount: state.summary.totalExpense,
                    color: context.palette.expense,
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
    final sections = t.dashboard.sections;

    return [
      SliverToBoxAdapter(child: _buildBalanceSkeleton(context)),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: sections.budgets,
            onTrailingTap: () =>
                widget.onNavigateToTab?.call(AppRootTab.budgets),
          ),
        ),
      ),
      SliverToBoxAdapter(child: _buildBudgetSkeleton(context)),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: sections.recentActivity,
            onTrailingTap: () =>
                widget.onNavigateToTab?.call(AppRootTab.activity),
          ),
        ),
      ),
      SliverToBoxAdapter(child: _buildRecentActivitySkeleton(context)),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: sections.spendingPatterns,
            onTrailingTap: () =>
                widget.onNavigateToTab?.call(AppRootTab.reports),
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
              borderRadius: AppSpacing.radiusCard,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PiconsRegular.warningCircle,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardBloc>().add(RefreshDashboard()),
                    child: Text(t.common.tryAgain),
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
    final sections = t.dashboard.sections;

    return [
      SliverToBoxAdapter(child: _buildBalanceCard(context, state)),
      const SliverToBoxAdapter(child: AutoImportPromptCard()),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: sections.budgets,
            onTrailingTap: () =>
                widget.onNavigateToTab?.call(AppRootTab.budgets),
          ),
        ),
      ),
      _buildBudgetsSection(),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: sections.recentActivity,
            onTrailingTap: () =>
                widget.onNavigateToTab?.call(AppRootTab.activity),
          ),
        ),
      ),
      _buildRecentTransactionsSection(state.summary.recentTransactions),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: DashboardSectionHeader(
            title: sections.spendingPatterns,
            onTrailingTap: () =>
                widget.onNavigateToTab?.call(AppRootTab.reports),
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
                borderRadius: AppSpacing.radiusControl,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: AppEmptyState(
                  icon: PiconsRegular.wallet,
                  message: t.dashboard.noBudgets,
                  actionLabel: t.common.newBudget,
                  onAction: () => context.push('/budgets/new'),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: AppCard(
              borderRadius: AppSpacing.radiusControl,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  for (var i = 0; i < data.budgetPreviews.length; i++) ...[
                    _BudgetPreviewTile(
                      preview: data.budgetPreviews[i],
                      currencyFmt: currencyFmt,
                      onTap: () => context.push(
                        '/budgets/${data.budgetPreviews[i].progress.budgetId}',
                      ),
                    ),
                    if (i != data.budgetPreviews.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.smd),
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
          final categoriesById = snapshot.data?.categoriesById ?? const {};

          if (transactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: AppCard(
                borderRadius: AppSpacing.radiusControl,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: AppEmptyState(
                  icon: PiconsRegular.receipt,
                  message: t.dashboard.noTransactions,
                  actionLabel: t.common.addExpense,
                  onAction: () => unawaited(_addRecord()),
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
                : categoriesById[record.categoryId]?.displayName;
            children.add(
              _RecentTile(
                record: record,
                fmt: currencyFmt,
                categoryName: categoryName,
                category: categoriesById[record.categoryId],
                onTap: () => _editRecord(record),
              ),
            );
            if (i < recentTwo.length - 1) {
              children.add(Divider(height: 1, color: dividerColor));
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: AppCard(
              borderRadius: AppSpacing.radiusControl,
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
              previousPeriodLabel: dateRange.previousPeriodNoun,
              trend: snapshot.data ?? [],
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: ShimmerBox(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(children: List.generate(2, _buildSkeletonBudgetRow)),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonBudgetRow(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: index == 1 ? 0 : AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              ShimmerBox.circle(size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: ShimmerBox.textLine(width: 120, height: 14)),
              const SizedBox(width: AppSpacing.sm),
              ShimmerBox.textLine(width: 90, height: 12),
            ],
          ),
          const SizedBox(height: AppSpacing.smd),
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        child: ShimmerBox(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox.textLine(width: 96, height: 12),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox.textLine(width: 180, height: 32),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: shimmerTextLine),
                    const SizedBox(width: AppSpacing.lg),
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: const ShimmerBox(
          child: Column(
            children: [
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: ShimmerBox(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(14, _buildSkeletonTrendBar),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox.textLine(width: 120, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonTrendBar(int index) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: index == 13 ? 0 : AppSpacing.xs),
        child: ShimmerBox.rectangle(
          width: double.infinity,
          height: 12 + (index % 5) * 6,
        ),
      ),
    );
  }

  GetBudgetsWithProgress? _tryGetBudgetsWithProgress() {
    if (!di.getIt.isRegistered<GetBudgetsWithProgress>()) return null;

    return di.getIt<GetBudgetsWithProgress>();
  }

  GetSpendingTrend? _tryGetSpendingTrend() {
    if (!di.getIt.isRegistered<GetSpendingTrend>()) return null;

    return di.getIt<GetSpendingTrend>();
  }

  // Theme and everything else live in Settings (docs/adr/0006).
  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final isAuth = context.read<AuthBloc>().state is Authenticated;
    final menu = t.dashboard.menu;

    return [
      if (isAuth)
        PopupMenuItem(
          value: 'settings',
          child: MenuRow(icon: PiconsRegular.user, text: menu.profile),
        )
      else
        PopupMenuItem(
          value: 'sign_in',
          child: MenuRow(icon: PiconsRegular.signIn, text: menu.signIn),
        ),
      PopupMenuItem(
        value: 'settings',
        child: MenuRow(icon: PiconsRegular.gear, text: menu.settings),
      ),
      if (isAuth) ...[
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'sign_out',
          child: MenuRow(icon: PiconsRegular.signOut, text: menu.signOut),
        ),
      ],
    ];
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'settings':
        context.push('/settings');
      case 'sign_in':
        context.push('/login');
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
  void dispose() {
    widget.refreshTick?.removeListener(_onExternalRefresh);
    _scanOpening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final firstName = _firstName(authState);
        final displayName = firstName ?? t.dashboard.userFallback;
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
                        greeting: _greeting(firstName),
                        avatar: _buildAvatarWidget(
                          context,
                          authState,
                          displayName,
                          photoUrl,
                        ),
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
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (preview.emoji != null) ...[
                  Text(preview.emoji ?? '', style: AppTypography.bodyLarge),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    preview.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  t.dashboard.budgetSpentOf(
                    spent: currencyFmt.format(preview.progress.spentAmount),
                    total: currencyFmt.format(preview.progress.effectiveAmount),
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface.withAlpha(170),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.smd),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
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
  // Getters, not cached: DateFormat keeps the language it was created in.
  static DateFormat get _timeFormat => DateFormat('h:mm a');
  static DateFormat get _dayFormat => DateFormat('MMM d');

  final Record record;
  final NumberFormat fmt;
  final String? categoryName;
  final cat.Category? category;
  final VoidCallback? onTap;

  const _RecentTile({
    this.onTap,
    required this.record,
    required this.fmt,
    this.categoryName,
    this.category,
  });

  String _timeLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(record.date.year, record.date.month, record.date.day);
    final difference = today.difference(date).inDays;

    if (difference == 0) return _timeFormat.format(record.date);
    if (difference == 1) return t.common.dates.yesterday;

    return _dayFormat.format(record.date);
  }

  Widget _leading(BuildContext context, bool isExpense) {
    final recordCategory = category;
    if (recordCategory != null) {
      return CategoryTile(
        colorHex: recordCategory.color,
        iconKey: recordCategory.emoji,
      );
    }

    // Uncategorized: a neutral tile so rows still line up.
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Icon(
        isExpense ? PiconsRegular.receipt : PiconsRegular.wallet,
        size: 20,
        color: context.palette.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isExpense = record.recordType == RecordType.expense;
    final amountColor = isExpense
        ? context.palette.expense
        : context.palette.income;
    final mutedColor = colors.onSurface.withAlpha(140);
    final displayName = record.recordType.displayName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        child: Row(
          children: [
            _leading(context, isExpense),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.description.isEmpty
                        ? displayName
                        : record.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    categoryName ?? displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.smd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${fmt.format(record.amount.abs())}',
                  semanticsLabel: CurrencyFormatter.semanticsLabel(
                    record.amount,
                    isExpense: isExpense,
                  ),
                  style: AppTypography.titleMedium.copyWith(color: amountColor),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _timeLabel(),
                  style: AppTypography.bodySmall.copyWith(color: mutedColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTileSkeleton extends StatelessWidget {
  const _RecentActivityTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      child: Row(
        children: [
          ShimmerBox.circle(size: 40),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox.textLine(height: 14),
                const SizedBox(height: AppSpacing.xs),
                ShimmerBox.textLine(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox.textLine(width: 60, height: 16),
              const SizedBox(height: AppSpacing.xs),
              ShimmerBox.textLine(width: 48, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
