import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
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
import 'record_form_page.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
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

  Widget _buildRecordsList() {
    return BlocBuilder<RecordBloc, RecordState>(
      buildWhen: (previous, current) =>
          current is RecordLoaded ||
          current is RecordError ||
          current is RecordLoading ||
          current is RecordLoadingMore,
      builder: (context, state) {
        if (state is RecordLoading) {
          return _buildShimmerList();
        }

        if (state is RecordError) {
          return Center(child: Text(state.message));
        }

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

        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
            itemCount: records.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= records.length) {
                return _buildLoadMore(isLoadingMore);
              }

              final record = records[index];

              return RecordCard(
                record: record,
                onTap: () => _navigateToForm(context, record),
                onDelete: () => _handleDelete(context, record),
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
    if (state is RecordLoaded) {
      return (state.filteredRecords, state.hasMore, false);
    }

    if (state is RecordLoadingMore) {
      return (state.currentRecords, true, true);
    }

    return (<Record>[], false, false);
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
    final recordBloc = context.read<RecordBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: recordBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: RecordFormPage(record: record),
        ),
      ),
    );
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

    if (state is RecordLoaded) {
      startDate = state.filterStartDate;
      endDate = state.filterEndDate;
      categoryIds = state.filterCategoryIds;
      recordType = state.filterRecordType;
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
      actions: [
        IconButton(
          icon: Icon(PiconsLight.funnel),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
          onPressed: () => _showFilterModal(context),
        ),
      ],
      child: Column(
        children: [
          AppSearchBar(
            controller: _searchCtrl,
            hintText: 'Search transactions...',
            onChanged: (v) => context.read<RecordBloc>().add(SearchRecords(v)),
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
