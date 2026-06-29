import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';

import '../../domain/entities/recurring_transaction.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';

class RecurringListPage extends StatelessWidget {
  final RecurringBloc bloc;

  const RecurringListPage({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: bloc, child: const RecurringListView());
  }
}

class RecurringListView extends StatefulWidget {
  const RecurringListView({super.key});

  @override
  State<RecurringListView> createState() => _RecurringListViewState();
}

class _RecurringListViewState extends State<RecurringListView> {
  @override
  void initState() {
    super.initState();
    context.read<RecurringBloc>().add(LoadRecurring());
  }

  void _onListener(BuildContext context, RecurringState state) {
    switch (state) {
      case RecurringOperationSuccess():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Operation successful')));
      case RecurringError(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      default:
        break;
    }
  }

  void _onRefresh() {
    context.read<RecurringBloc>().add(LoadRecurring());
  }

  void _onSwitchChanged(RecurringTransaction recurring, bool value) {
    context.read<RecurringBloc>().add(
      UpdateRecurring(recurring.copyWith(isActive: value)),
    );
  }

  void _onDeleteDialogConfirm(
    BuildContext context,
    RecurringTransaction recurring,
  ) {
    final id = recurring.id;
    if (id == null) return;
    if (!context.mounted) return;
    Navigator.pop(context);
    context.read<RecurringBloc>().add(DeleteRecurring(id));
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PiconsRegular.arrowsCounterClockwise,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No recurring transactions',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first recurring expense',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringItem(
    RecurringTransaction recurring,
    DateFormat dateFormat,
  ) {
    final isDue = recurring.isDue();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDue
              ? Theme.of(context).colorScheme.tertiary.withAlpha(51)
              : Theme.of(context).colorScheme.onSurface.withAlpha(26),
          child: Icon(
            PiconsRegular.arrowsCounterClockwise,
            color: isDue
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.onSurfaceVariant,
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
                color: isDue
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: recurring.isActive,
          onChanged: (value) => _onSwitchChanged(recurring, value),
        ),
        onTap: () => _navigateToForm(context, recurring),
        onLongPress: () => _showDeleteDialog(context, recurring),
      ),
    );
  }

  Widget _buildLoadedState(RecurringLoaded state, DateFormat dateFormat) {
    final items = state.recurringList;

    if (items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildRecurringItem(items[index], dateFormat),
      ),
    );
  }

  void _navigateToForm(BuildContext context, RecurringTransaction? recurring) {
    if (recurring?.id != null) {
      context.push('/recurring/${recurring!.id}/edit');
    } else {
      context.push('/recurring/new');
    }
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
            onPressed: () => _onDeleteDialogConfirm(dialogContext, recurring),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(RecurringError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PiconsRegular.warningCircle,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(state.message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<RecurringBloc>().add(LoadRecurring()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext _, RecurringState state) {
    return switch (state) {
      RecurringLoading() => const Center(child: CircularProgressIndicator()),
      RecurringError() => _buildErrorState(state),
      RecurringLoaded() => _buildLoadedState(state, DateFormat('MMM dd, yyyy')),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        actions: [
          IconButton(
            icon: Icon(PiconsRegular.arrowsCounterClockwise),
            onPressed: () =>
                context.read<RecurringBloc>().add(const ProcessRecurring()),
            tooltip: 'Process pending',
          ),
        ],
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: _onListener,
        builder: _buildBody,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context, null),
        child: Icon(PiconsRegular.plus),
      ),
    );
  }
}
