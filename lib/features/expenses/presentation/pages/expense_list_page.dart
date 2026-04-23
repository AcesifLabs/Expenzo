import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/skeletons/expense_list_skeleton.dart';
import '../../../../shared/presentation/widgets/shimmer_box.dart';
import 'expense_form_page.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import '../../../sms_parser/presentation/bloc/sms_scanner_event.dart';
import '../../../sms_parser/presentation/pages/sms_scan_page.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
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
      context.read<ExpenseBloc>().add(const LoadMoreExpenses());
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
                  'Scan past SMS for expenses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(LucideIcons.history),
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
                leading: const Icon(LucideIcons.calendarDays),
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
                leading: const Icon(LucideIcons.calendarRange),
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
                leading: const Icon(LucideIcons.infinity),
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
          // Refresh expenses list when returning
          context.read<ExpenseBloc>().add(const RefreshExpenses());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.filter), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.settings),
            onSelected: (value) {
              if (value == 'scan') {
                _showScanOptions(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'scan',
                child: Row(
                  children: [
                    Icon(LucideIcons.scan, size: 20),
                    SizedBox(width: 8),
                    Text('Scan previous expenses from SMS'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        buildWhen: (previous, current) =>
            current is ExpenseLoaded ||
            current is ExpenseError ||
            current is ExpenseLoading ||
            current is ExpenseLoadingMore,
        builder: (context, state) {
          if (state is ExpenseLoading) {
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
          if (state is ExpenseError) {
            return Center(child: Text(state.message));
          }

          List<Expense> expenses = [];
          bool hasMore = false;
          bool isLoadingMore = false;

          if (state is ExpenseLoaded) {
            expenses = state.expenses;
            hasMore = state.hasMore;
          } else if (state is ExpenseLoadingMore) {
            expenses = state.currentExpenses;
            hasMore = true;
            isLoadingMore = true;
          }

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.receipt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first expense',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExpenseBloc>().add(const RefreshExpenses());
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: expenses.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= expenses.length) {
                  return _buildLoadMoreIndicator(isLoadingMore);
                }
                final expense = expenses[index];
                return ExpenseCard(
                  expense: expense,
                  onTap: () => _navigateToForm(context, expense),
                  onDelete: () => _handleDelete(context, expense),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context, null),
        child: const Icon(LucideIcons.plus),
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

  void _navigateToForm(BuildContext context, Expense? expense) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ExpenseBloc>()),
            BlocProvider.value(value: context.read<CategoryBloc>()),
          ],
          child: ExpenseFormPage(expense: expense),
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context, Expense expense) {
    final bloc = context.read<ExpenseBloc>();
    bloc.add(DeleteExpenseEvent(expense.id!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        duration: AppConstants.briefSnackbarDuration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            bloc.add(AddExpenseEvent(expense));
          },
        ),
      ),
    );
  }
}
