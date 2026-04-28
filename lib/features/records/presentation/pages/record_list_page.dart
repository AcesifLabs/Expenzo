import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
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
import 'record_form_page.dart';
import '../../../sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import '../../../sms_parser/presentation/bloc/sms_scanner_event.dart';
import '../../../sms_parser/presentation/pages/sms_scan_page.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RecordBloc>().add(const LoadMoreRecords());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Activity',
      actions: [
        IconButton(
          icon: Icon(
            PhosphorIcons.listMagnifyingGlass(PhosphorIconsStyle.light),
          ),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
          onPressed: () => _showScanOptions(context),
        ),
        IconButton(
          icon: Icon(PhosphorIcons.funnel(PhosphorIconsStyle.light)),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
          onPressed: () {},
        ),
      ],
      child: Column(
        children: [
          AppSearchBar(
            controller: _searchCtrl,
            hintText: 'Search transactions...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          Expanded(child: _buildRecordsList()),
        ],
      ),
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
        if (state is RecordLoading) {
          return ShimmerList(
            itemCount: 6,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ListTile(
                leading: ShimmerBox.circle(size: 40),
                title: ShimmerBox.textLine(width: 150),
                subtitle: ShimmerBox.textLine(width: 100),
              ),
            ),
          );
        }
        if (state is RecordError) {
          return Center(child: Text(state.message));
        }

        List<Record> records = [];
        bool hasMore = false;
        bool isLoadingMore = false;

        if (state is RecordLoaded) {
          records = state.records;
          hasMore = state.hasMore;
        } else if (state is RecordLoadingMore) {
          records = state.currentRecords;
          hasMore = true;
          isLoadingMore = true;
        }

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          records = records
              .where((r) => r.description.toLowerCase().contains(q))
              .toList();
        }

        if (records.isEmpty) {
          return const AppEmptyState(
            icon: Icons.list,
            message: 'No transactions found',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<RecordBloc>().add(const RefreshRecords());
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: records.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= records.length) {
                return _buildLoadMore(isLoadingMore);
              }
              final record = records[index];
              final catState = context.read<CategoryBloc>().state;
              String? catName;
              String? catEmoji;
              String? catColor;
              if (catState is CategoryLoaded) {
                final cat = catState.categories.where(
                  (c) => c.id == record.categoryId,
                );
                if (cat.isNotEmpty) {
                  catName = cat.first.name;
                  catEmoji = cat.first.emoji;
                  catColor = cat.first.color;
                }
              }
              return RecordCard(
                record: record,
                categoryName: catName,
                categoryEmoji: catEmoji,
                categoryColor: catColor,
                onTap: () => _navigateToForm(context, record),
                onDelete: () => _handleDelete(context, record),
              );
            },
          ),
        );
      },
    );
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

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Scan past SMS for records',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(
                  PhosphorIcons.clockCounterClockwise(
                    PhosphorIconsStyle.regular,
                  ),
                ),
                title: const Text('Last 7 Days'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(
                    context,
                    DateTime.now().subtract(const Duration(days: 7)),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                ),
                title: const Text('Last 30 Days'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(
                    context,
                    DateTime.now().subtract(const Duration(days: 30)),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  PhosphorIcons.calendarDots(PhosphorIconsStyle.regular),
                ),
                title: const Text('Last 3 Months'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(
                    context,
                    DateTime.now().subtract(const Duration(days: 90)),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  PhosphorIcons.infinity(PhosphorIconsStyle.regular),
                ),
                title: const Text('All Time'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(context, DateTime(2000));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startScan(BuildContext context, DateTime since) {
    final smsBloc = di.getIt<SmsScannerBloc>();
    smsBloc.add(StartScan(since: since, filterDuplicates: true));
    Navigator.of(context)
        .push(
          SlidePageRoute(
            builder: (_) => BlocProvider.value(
              value: smsBloc,
              child: const SmsScanResultsPage(),
            ),
          ),
        )
        .then((_) {
          context.read<RecordBloc>().add(const RefreshRecords());
        });
  }

  void _navigateToForm(BuildContext context, Record? record) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RecordBloc>(),
          child: RecordFormPage(record: record),
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context, Record record) {
    final bloc = context.read<RecordBloc>();
    bloc.add(DeleteRecordEvent(record.id!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Record deleted'),
        duration: AppConstants.briefSnackbarDuration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            bloc.add(AddRecordEvent(record));
          },
        ),
      ),
    );
  }
}
