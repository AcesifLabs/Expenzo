import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_form_page.dart';

class RecurringListPage extends StatefulWidget {
  const RecurringListPage({super.key});

  @override
  State<RecurringListPage> createState() => _RecurringListPageState();
}

class _RecurringListPageState extends State<RecurringListPage> {
  late RecurringBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.getIt<RecurringBloc>();
    _bloc.add(LoadRecurring());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String _frequencyLabel(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recurring Transactions'),
          actions: [
            IconButton(
              icon: Icon(PiconsRegular.arrowsClockwise),
              onPressed: () => _bloc.add(const ProcessRecurring()),
              tooltip: 'Process pending',
            ),
          ],
        ),
        body: BlocConsumer<RecurringBloc, RecurringState>(
          listener: (context, state) {
            if (state is RecurringOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is RecurringError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is RecurringLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecurringError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PiconsRegular.warningCircle,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(LoadRecurring()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is RecurringLoaded) {
              final items = state.recurringList;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PiconsRegular.arrowsCounterClockwise,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recurring transactions',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to create your first recurring expense',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(LoadRecurring());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final recurring = items[index];
                    final isDue = recurring.isDue();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDue
                              ? Colors.orange.withAlpha(51)
                              : Colors.grey.withAlpha(26),
                          child: Icon(
                            PiconsRegular.arrowsCounterClockwise,
                            color: isDue ? Colors.orange : Colors.grey,
                          ),
                        ),
                        title: Text(recurring.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${recurring.amount.toStringAsFixed(2)} - ${_frequencyLabel(recurring.frequency)}',
                            ),
                            Text(
                              'Next: ${dateFormat.format(recurring.nextOccurrence)}',
                              style: TextStyle(
                                color: isDue ? Colors.orange : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Switch(
                          value: recurring.isActive,
                          onChanged: (value) {
                            _bloc.add(
                              UpdateRecurring(
                                recurring.copyWith(isActive: value),
                              ),
                            );
                          },
                        ),
                        onTap: () => _navigateToForm(context, recurring),
                        onLongPress: () =>
                            _showDeleteDialog(context, recurring),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToForm(context, null),
          child: Icon(PiconsRegular.plus),
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, RecurringTransaction? recurring) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: _bloc,
          child: RecurringFormPage(recurring: recurring),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RecurringTransaction recurring) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Recurring'),
        content: Text(
          'Are you sure you want to delete "${recurring.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _bloc.add(DeleteRecurring(recurring.id!));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
