import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import '../../domain/entities/record.dart';
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';
import '../bloc/record_state.dart';
import '../widgets/record_card.dart';
import '../../../../shared/presentation/widgets/shimmer_box.dart';
import 'record_form_page.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          // Refresh records list when returning
          context.read<RecordBloc>().add(const RefreshRecords());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.funnel(PhosphorIconsStyle.regular)),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: Icon(PhosphorIcons.faders(PhosphorIconsStyle.regular)),
            onSelected: (value) {
              if (value == 'scan') {
                _showScanOptions(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'scan',
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.listMagnifyingGlass(
                        PhosphorIconsStyle.regular,
                      ),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text('Scan previous records from SMS'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<RecordBloc, RecordState>(
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.invoice(PhosphorIconsStyle.regular),
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No records yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first record',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RepaintBoundary(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<RecordBloc>().add(const RefreshRecords());
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: records.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= records.length) {
                    return _buildLoadMoreIndicator(isLoadingMore);
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isLoadingMore) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: isLoadingMore
          ? const CircularProgressIndicator()
          : const Text('Scroll for more...'),
    );
  }

  void _navigateToForm(BuildContext context, Record? record) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<RecordBloc>()),
            BlocProvider.value(value: context.read<CategoryBloc>()),
          ],
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
