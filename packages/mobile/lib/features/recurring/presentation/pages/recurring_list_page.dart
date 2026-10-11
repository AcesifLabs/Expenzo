import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../../domain/entities/recurring_transaction.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Lists recurring transactions. Expects a [RecurringBloc] above it.
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
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(t.recurring.saved)));
      case RecurringError(:final message):
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
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

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PiconsRegular.arrowsCounterClockwise,
            size: 64,
            color: colorScheme.onSurface.withAlpha(100),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.recurring.empty.title,
            style: AppTypography.titleLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            t.recurring.empty.body,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringItem(
    RecurringTransaction recurring,
    DateFormat dateFormat,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDue = recurring.isDue();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDue
              ? colorScheme.tertiary.withAlpha(51)
              : colorScheme.onSurface.withAlpha(26),
          child: Icon(
            PiconsRegular.arrowsCounterClockwise,
            color: isDue ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(recurring.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.recurring.amountEvery(
                amount: CurrencyFormatter.format(recurring.amount),
                frequency: recurring.frequency.displayName,
              ),
            ),
            Text(
              t.recurring.next(
                date: dateFormat.format(recurring.nextOccurrence),
              ),
              style: AppTypography.bodySmall.copyWith(
                color: isDue
                    ? colorScheme.tertiary
                    : colorScheme.onSurfaceVariant,
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildRecurringItem(items[index], dateFormat),
      ),
    );
  }

  Future<void> _navigateToForm(
    BuildContext context,
    RecurringTransaction? recurring,
  ) async {
    final recurringId = recurring?.id;
    final bloc = context.read<RecurringBloc>();
    final path = recurringId != null
        ? '/recurring/$recurringId/edit'
        : '/recurring/new';
    final saved = await context.push<bool>(path);
    // The form saves through its own bloc; refresh this list.
    if (saved == true) bloc.add(LoadRecurring());
  }

  void _showDeleteDialog(BuildContext context, RecurringTransaction recurring) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.recurring.delete.title),
        content: Text(t.recurring.delete.confirm(name: recurring.description)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => _onDeleteDialogConfirm(dialogContext, recurring),
            child: Text(
              t.common.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(RecurringError state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PiconsRegular.warningCircle, size: 48, color: colorScheme.error),
          const SizedBox(height: AppSpacing.md),
          Text(state.message),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => context.read<RecurringBloc>().add(LoadRecurring()),
            child: Text(t.common.tryAgain),
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
      appBar: AppPageHeader(
        leading: const AppBackButton(),
        title: t.recurring.title,
        actions: [
          IconButton(
            icon: const Icon(PiconsRegular.arrowsCounterClockwise),
            onPressed: () =>
                context.read<RecurringBloc>().add(const ProcessRecurring()),
            tooltip: t.recurring.processPending,
          ),
        ],
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: _onListener,
        builder: _buildBody,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context, null),
        tooltip: t.recurring.newTooltip,
        child: const Icon(PiconsRegular.plus),
      ),
    );
  }
}
