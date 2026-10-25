import 'dart:math';

import 'dart:async';

import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/nav_bar_metrics.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_search_bar.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import '../../domain/entities/record.dart';
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';
import '../bloc/record_state.dart';
import '../helpers/record_day_groups.dart';
import '../widgets/record_card.dart';
import '../widgets/record_filter_modal.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/categories/presentation/helpers/category_display_name.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';

class RecordListPage extends StatelessWidget {
  const RecordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.getIt<RecordBloc>()..add(const LoadRecords()),
        ),
        BlocProvider(
          create: (_) => di.getIt<CategoryBloc>()..add(const LoadCategories()),
        ),
      ],
      child: const RecordListView(),
    );
  }
}

class RecordListView extends StatefulWidget {
  const RecordListView({super.key});

  @override
  State<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RecordBloc>().add(const LoadMoreRecords());
    }
  }

  void _onRefresh() {
    context.read<RecordBloc>().add(const RefreshRecords());
  }

  CategoryInfo _resolveCategory(Record record, CategoryState catState) {
    if (catState is! CategoryLoaded) return const CategoryInfo();
    final matched = catState.categories.where((c) => c.id == record.categoryId);
    if (matched.isEmpty) return const CategoryInfo();

    return CategoryInfo(
      name: matched.first.displayName,
      emoji: matched.first.emoji,
      color: matched.first.color,
    );
  }

  Widget _buildError(RecordError state) => AppErrorState(
    message: state.message,
    onRetry: () => context.read<RecordBloc>().add(const LoadRecords()),
  );

  Widget _buildRecordsList() {
    return BlocBuilder<RecordBloc, RecordState>(
      buildWhen: (previous, current) =>
          current is RecordLoaded ||
          current is RecordError ||
          current is RecordLoading ||
          current is RecordLoadingMore,
      builder: (context, state) {
        if (state is RecordLoading) return _buildShimmerList();
        if (state is RecordError) return _buildError(state);

        final listState = _extractListState(state);
        final records = listState.$1;
        final hasMore = listState.$2;
        final isLoadingMore = listState.$3;

        if (records.isEmpty) {
          final filtered = _searchCtrl.text.isNotEmpty || _hasFilters(state);
          final listT = t.records.list;

          return filtered
              ? AppEmptyState(
                  icon: PiconsRegular.funnel,
                  message: listT.noMatches,
                )
              : AppEmptyState(
                  icon: PiconsRegular.receipt,
                  message: listT.empty,
                  actionLabel: t.common.addExpense,
                  onAction: () => _navigateToForm(context, null),
                );
        }

        final catState = context.watch<CategoryBloc>().state;

        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              for (final group in groupRecordsByDay(records))
                SliverMainAxisGroup(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _DayHeaderDelegate.measured(
                        dayHeaderLabel(group.day),
                        MediaQuery.textScalerOf(context),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverList.separated(
                        itemCount: group.records.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final record = group.records[index];

                          return RecordCard(
                            record: record,
                            onTap: () => _navigateToForm(context, record),
                            onDelete: () => _handleDelete(context, record),
                            categoryInfo: _resolveCategory(record, catState),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              if (hasMore)
                SliverToBoxAdapter(child: _buildLoadMore(isLoadingMore)),
              // Room for the last record above the floating nav bar.
              SliverToBoxAdapter(
                child: SizedBox(height: NavBarMetrics.clearance(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasFilters(RecordState state) => switch (state) {
    RecordLoaded(
      :final filterStartDate,
      :final filterEndDate,
      :final filterCategoryIds,
      :final filterRecordType,
    ) =>
      filterStartDate != null ||
          filterEndDate != null ||
          (filterCategoryIds?.isNotEmpty ?? false) ||
          filterRecordType != null,
    _ => false,
  };

  Widget _buildShimmerList() {
    return ShimmerList(
      itemCount: 6,
      itemBuilder: (context, index) => AppCard(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: ListTile(
          leading: ShimmerBox.circle(size: 40),
          title: ShimmerBox.textLine(width: 150),
          subtitle: ShimmerBox.textLine(width: 100),
        ),
      ),
    );
  }

  (List<Record>, bool, bool) _extractListState(RecordState state) {
    return switch (state) {
      RecordLoaded(:final filteredRecords, :final hasMore) => (
        filteredRecords,
        hasMore,
        false,
      ),
      RecordLoadingMore(:final currentRecords) => (currentRecords, true, true),
      _ => (<Record>[], false, false),
    };
  }

  Widget _buildLoadMore(bool isLoadingMore) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      alignment: Alignment.center,
      child: isLoadingMore
          ? const CircularProgressIndicator()
          : Text(
              t.records.list.scrollForMore,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }

  void _navigateToForm(BuildContext context, Record? record) {
    unawaited(showTransactionSheet(context, record: record));
  }

  void _onUndoDelete(Record record) {
    if (!mounted) return;
    context.read<RecordBloc>().add(AddRecordEvent(record));
  }

  void _handleDelete(BuildContext context, Record record) {
    final bloc = context.read<RecordBloc>();
    final recordId = record.id;
    if (recordId == null) return;
    bloc.add(DeleteRecordEvent(recordId));
    // Evict any visible/queued SnackBar so a burst of deletes surfaces one
    // toast (the newest) rather than a pile the user has to dismiss one by
    // one. This matters most here: a SnackBar carrying an action defaults to
    // `persist: true`, so without eviction each queued toast waits forever.
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(t.records.list.deleted),
          duration: AppConstants.undoSnackbarDuration,
          action: SnackBarAction(
            label: t.common.undo,
            onPressed: () => _onUndoDelete(record),
          ),
        ),
      );
  }

  void Function({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    String? recordType,
  })
  _onApplyFilters(RecordBloc recordBloc) {
    return ({startDate, endDate, categoryIds, recordType}) {
      recordBloc.add(
        ApplyFilters(
          startDate: startDate,
          endDate: endDate,
          categoryIds: categoryIds,
          recordType: recordType,
        ),
      );
    };
  }

  VoidCallback _onClearFilters(RecordBloc recordBloc) {
    return () {
      recordBloc.add(const ClearFilters());
    };
  }

  void _showFilterModal(BuildContext context) {
    final recordBloc = context.read<RecordBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final state = recordBloc.state;
    DateTime? startDate;
    DateTime? endDate;
    List<String>? categoryIds;
    String? recordType;

    if (state case RecordLoaded(
      :final filterStartDate,
      :final filterEndDate,
      :final filterCategoryIds,
      :final filterRecordType,
    )) {
      startDate = filterStartDate;
      endDate = filterEndDate;
      categoryIds = filterCategoryIds;
      recordType = filterRecordType;
    }

    showRecordFilterModal(
      context,
      FilterModalParams(
        recordBloc: recordBloc,
        categoryBloc: categoryBloc,
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
        recordType: recordType,
        onApply: _onApplyFilters(recordBloc),
        onClear: _onClearFilters(recordBloc),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listT = t.records.list;

    return AppScaffold(
      title: listT.title,
      subtitle: listT.subtitle,
      actions: [
        TextButton.icon(
          onPressed: () => _showFilterModal(context),
          icon: const Icon(PiconsRegular.funnel, size: 20),
          label: Text(listT.filter),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: AppSearchBar(
              controller: _searchCtrl,
              hintText: listT.search,
              onChanged: (v) =>
                  context.read<RecordBloc>().add(SearchRecords(v)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              // Dismissing the keyboard isn't an action a screen reader needs.
              excludeFromSemantics: true,
              child: Scrollbar(
                controller: _scrollController,
                child: _buildRecordsList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A pinned date heading ("Today", "Mon, 6 Oct") above each day's records.
class _DayHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;

  /// Grows with the text size: a pinned header can't size itself.
  final double extent;

  static const _minExtent = 40.0;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  const _DayHeaderDelegate(this.label, this.extent);

  /// Sized to fit [label] on one line at [textScaler].
  static _DayHeaderDelegate measured(String label, TextScaler textScaler) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: AppTypography.labelLarge),
      textScaler: textScaler,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final extent = max(_minExtent, painter.height + 2 * AppSpacing.sm);
    painter.dispose();

    return _DayHeaderDelegate(label, extent);
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Semantics(
        header: true,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_DayHeaderDelegate oldDelegate) =>
      oldDelegate.label != label || oldDelegate.extent != extent;
}
