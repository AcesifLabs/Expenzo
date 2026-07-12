import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_search_bar.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import '../../domain/entities/record.dart';
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';
import '../bloc/record_state.dart';
import '../widgets/record_card.dart';
import '../widgets/record_filter_modal.dart';

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
      name: matched.first.name,
      emoji: matched.first.emoji,
      color: matched.first.color,
    );
  }

  Widget _buildRecordsList() {
    return BlocBuilder<RecordBloc, RecordState>(
      buildWhen: (previous, current) =>
          current is RecordLoaded ||
          current is RecordError ||
          current is RecordLoading ||
          current is RecordLoadingMore,
      builder: (context, state) {
        if (state is RecordLoading) return _buildShimmerList();
        if (state is RecordError) return Center(child: Text(state.message));

        final listState = _extractListState(state);
        final records = listState.$1;
        final hasMore = listState.$2;
        final isLoadingMore = listState.$3;

        if (records.isEmpty) {
          return AppEmptyState(
            icon: PiconsRegular.list,
            message: 'No transactions found',
          );
        }

        final catState = context.watch<CategoryBloc>().state;

        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
            itemCount: records.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= records.length) {
                return _buildLoadMore(isLoadingMore);
              }

              final record = records[index];

              return RecordCard(
                record: record,
                onTap: () => _navigateToForm(context, record),
                onDelete: () => _handleDelete(context, record),
                categoryInfo: _resolveCategory(record, catState),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ShimmerList(
      itemCount: 6,
      itemBuilder: (context, index) => AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: isLoadingMore
          ? const CircularProgressIndicator()
          : Text(
              'Scroll for more...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
              ),
            ),
    );
  }

  void _navigateToForm(BuildContext context, Record? record) {
    final extra = <String, dynamic>{
      'recordBloc': context.read<RecordBloc>(),
      'categoryBloc': context.read<CategoryBloc>(),
    };
    final recordId = record?.id;
    if (recordId != null) {
      context.push('/records/$recordId/edit', extra: extra);
    } else {
      context.push('/records/new', extra: extra);
    }
  }

  void _onUndoDelete(Record record) {
    context.read<RecordBloc>().add(AddRecordEvent(record));
  }

  void _handleDelete(BuildContext context, Record record) {
    final bloc = context.read<RecordBloc>();
    final recordId = record.id;
    if (recordId == null) return;
    bloc.add(DeleteRecordEvent(recordId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Record deleted'),
        duration: AppConstants.briefSnackbarDuration,
        action: SnackBarAction(
          label: 'Undo',
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
    return AppScaffold(
      title: 'Activity',
      subtitle: 'Transaction history',
      actions: [
        IconButton(
          icon: Icon(PiconsLight.funnel),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
          onPressed: () => _showFilterModal(context),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: AppSearchBar(
              controller: _searchCtrl,
              hintText: 'Search transactions...',
              onChanged: (v) =>
                  context.read<RecordBloc>().add(SearchRecords(v)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
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
