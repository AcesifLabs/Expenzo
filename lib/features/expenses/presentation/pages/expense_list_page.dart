import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_card.dart';
import 'expense_form_page.dart';
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
                leading: const Icon(Icons.history),
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
                leading: const Icon(Icons.date_range),
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
                leading: const Icon(Icons.calendar_month),
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
                leading: const Icon(Icons.all_inclusive),
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
          MaterialPageRoute(
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
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
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
                    Icon(Icons.sms_failed_outlined, size: 20),
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
            return const Center(child: CircularProgressIndicator());
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
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
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
        child: const Icon(Icons.add),
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
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ExpenseBloc>(),
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
