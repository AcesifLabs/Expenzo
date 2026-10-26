import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_section.dart';

import '../../domain/entities/recurring_transaction.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';
import '../widgets/recurring_defaults_section.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class RecurringListView extends StatefulWidget {
  const RecurringListView({super.key});

  @override
  State<RecurringListView> createState() => _RecurringListViewState();
}

class _RecurringListViewState extends State<RecurringListView> {
  List<RecurringTransaction>? _lastItems;

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
      case RecurringProcessed(:final created, :final automatic):
        _showProcessed(context, created, automatic: automatic);
      case RecurringError(:final message):
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
      default:
        break;
    }
  }

  void _showProcessed(
    BuildContext context,
    int created, {
    required bool automatic,
  }) {
    if (created == 0 && automatic) return;
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    messenger.showSnackBar(
      created > 0
          ? SnackBar(content: Text(t.recurring.posted(n: created)))
          : SnackBar(
              content: Text(t.recurring.nothingDue),
              duration: AppConstants.briefSnackbarDuration,
            ),
    );
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
    final emptyT = t.recurring.empty;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            PiconsRegular.arrowsCounterClockwise,
            size: 64,
            color: colorScheme.onSurface.withAlpha(100),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            emptyT.title,
            style: AppTypography.titleLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            emptyT.body,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringItem(
    RecurringTransaction recurring,
    DateFormat dateFormat, {
    required bool interactive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDue = recurring.isDue();

    return ListTile(
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
            t.recurring.next(date: dateFormat.format(recurring.nextOccurrence)),
            style: AppTypography.bodySmall.copyWith(
              color: isDue
                  ? colorScheme.tertiary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),

      trailing: Semantics(
        label: recurring.description,
        child: Switch(
          value: recurring.isActive,
          onChanged: interactive
              ? (value) => _onSwitchChanged(recurring, value)
              : null,
        ),
      ),
      onTap: interactive ? () => _navigateToForm(context, recurring) : null,
      onLongPress: interactive
          ? () => _showDeleteDialog(context, recurring)
          : null,
    );
  }

  Widget _buildLoadedState(
    List<RecurringTransaction> items, {
    bool interactive = true,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final before = <Widget>[
      const RecurringDefaultsSection(),
      if (items.isNotEmpty)
        SettingsSectionHeader(title: t.recurring.sections.active),
    ];
    final after = <Widget>[
      if (items.isEmpty) _buildEmptyState(),

      const SizedBox(height: AppSpacing.xxl + AppSpacing.xl),
    ];

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        padding: AppSpacing.pagePadding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: before.length + items.length + after.length,
        itemBuilder: (_, index) {
          if (index < before.length) return before[index];
          final row = index - before.length;
          if (row >= items.length) return after[row - items.length];

          return SettingsSectionSlot(
            isFirst: row == 0,
            isLast: row == items.length - 1,
            child: _buildRecurringItem(
              items[row],
              dateFormat,
              interactive: interactive,
            ),
          );
        },
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

    if (saved == true) bloc.add(LoadRecurring());
  }

  void _showDeleteDialog(BuildContext context, RecurringTransaction recurring) {
    final deleteT = t.recurring.delete;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(deleteT.title),
        content: Text(deleteT.confirm(name: recurring.description)),
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
    if (state is RecurringLoaded) _lastItems = state.recurringList;
    final lastItems = _lastItems;

    return switch (state) {
      RecurringLoaded(:final recurringList) => _buildLoadedState(recurringList),
      RecurringInitial() => const SizedBox.shrink(),
      RecurringLoading() when lastItems != null => _buildLoadedState(
        lastItems,
        interactive: false,
      ),
      _ when lastItems != null => _buildLoadedState(lastItems),
      RecurringError() => _buildErrorState(state),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildProcessButton(BuildContext _, RecurringState state) {
    return IconButton(
      icon: const Icon(PiconsRegular.arrowsCounterClockwise),

      onPressed: state is RecurringLoading ? null : _onProcessPending,
      tooltip: t.recurring.processPending,
    );
  }

  void _onProcessPending() {
    context.read<RecurringBloc>().add(const ProcessRecurring());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppPageHeader(
        leading: const AppBackButton(),
        title: t.recurring.title,
        actions: [
          BlocBuilder<RecurringBloc, RecurringState>(
            builder: _buildProcessButton,
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
