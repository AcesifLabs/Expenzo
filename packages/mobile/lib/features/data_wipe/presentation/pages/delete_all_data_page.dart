import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_section.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/local_data_summary.dart';
import '../bloc/delete_all_data_bloc.dart';
import '../bloc/delete_all_data_event.dart';
import '../bloc/delete_all_data_state.dart';
import '../helpers/refresh_after_local_wipe.dart';

class DeleteAllDataPage extends StatelessWidget {
  const DeleteAllDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.getIt<DeleteAllDataBloc>()..add(const DeleteAllDataStarted()),
      child: const Scaffold(
        resizeToAvoidBottomInset: true,
        body: DeleteAllDataView(),
      ),
    );
  }
}

/// Delete all data: what will go, a typed DELETE, then the delete. The
/// design's checkbox is replaced by typing the word.
class DeleteAllDataView extends StatelessWidget {
  const DeleteAllDataView({super.key});

  Widget _buildBody(BuildContext context, DeleteAllDataState state) {
    final deleteDataT = t.settings.deleteData;
    final deleting = state.status == DeleteAllDataStatus.deleting;

    // Leaving mid-delete is blocked: no back button, and system back is off.
    return PopScope(
      canPop: !deleting,
      child: AppScaffold(
        title: deleteDataT.title,
        leading: deleting ? null : const AppBackButton(),
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            _WarningCard(isSignedIn: state.isSignedIn),
            if (state.status == DeleteAllDataStatus.loading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _SummarySection(summary: state.summary),
            SettingsSection(
              title: deleteDataT.sections.confirmation,
              children: [
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: deleteDataT.confirmHint,
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    enabled: !deleting,
                    onChanged: (text) => _onConfirmationChanged(context, text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _DeleteButton(state: state, onDelete: () => _onDelete(context)),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _onConfirmationChanged(BuildContext context, String text) {
    context.read<DeleteAllDataBloc>().add(DeleteConfirmationChanged(text));
  }

  void _onDelete(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<DeleteAllDataBloc>().add(const DeleteAllRequested());
  }

  bool _isOutcome(DeleteAllDataState previous, DeleteAllDataState current) =>
      current.status != previous.status &&
      (current.status == DeleteAllDataStatus.failed ||
          current.status == DeleteAllDataStatus.done);

  void _onOutcome(BuildContext context, DeleteAllDataState state) {
    // Captured first: the refresh leaves this page.
    final messenger = ScaffoldMessenger.of(context);
    if (state.status == DeleteAllDataStatus.done) {
      refreshAfterLocalWipe(context);
    }
    final message = state.status == DeleteAllDataStatus.done
        ? t.settings.deleteData.done
        : state.errorMessage;
    if (message == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAllDataBloc, DeleteAllDataState>(
      listenWhen: _isOutcome,
      listener: _onOutcome,
      builder: _buildBody,
    );
  }
}

class _WarningCard extends StatelessWidget {
  final bool isSignedIn;

  const _WarningCard({required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    final deleteDataT = t.settings.deleteData;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final body = isSignedIn
        ? '${deleteDataT.warningBodySignedIn} ${deleteDataT.otherDevicesNote}'
        : deleteDataT.warningBody;

    return AppCard(
      backgroundColor: palette.expenseTint,
      borderRadius: AppSpacing.radiusCard,
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PiconsRegular.warning, color: palette.expense),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deleteDataT.warningTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What will be deleted. Without a [summary] (counting failed) the rows show
/// no counts; the delete still runs.
class _SummarySection extends StatelessWidget {
  final LocalDataSummary? summary;

  const _SummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final deleteDataT = t.settings.deleteData;
    final summary = this.summary;
    final goals = summary?.goals;

    return SettingsSection(
      title: deleteDataT.sections.summary,
      children: [
        _SummaryRow(
          icon: PiconsRegular.receipt,
          label: deleteDataT.transactions,
          value: summary == null
              ? null
              : deleteDataT.transactionsCount(n: summary.transactions),
        ),
        _SummaryRow(
          icon: PiconsRegular.wallet,
          label: deleteDataT.budgets,
          value: summary == null
              ? null
              : deleteDataT.budgetsCount(n: summary.budgets),
        ),
        _SummaryRow(
          icon: PiconsRegular.tag,
          label: deleteDataT.categories,
          value: summary == null
              ? null
              : deleteDataT.categoriesCount(n: summary.categories),
          note: deleteDataT.categoriesNote,
        ),
        _SummaryRow(
          icon: PiconsRegular.repeat,
          label: deleteDataT.recurring,
          value: summary == null
              ? null
              : deleteDataT.recurringCount(n: summary.recurring),
        ),
        _SummaryRow(
          icon: PiconsRegular.chatText,
          label: deleteDataT.smsRules,
          value: summary == null
              ? null
              : deleteDataT.smsRulesCount(n: summary.smsRules),
        ),
        if (goals != null)
          _SummaryRow(
            icon: PiconsRegular.target,
            label: deleteDataT.goals,
            value: deleteDataT.goalsCount(n: goals),
          ),
        _SummaryRow(
          icon: PiconsRegular.gear,
          label: deleteDataT.settings,
          value: deleteDataT.settingsValue,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String? note;

  const _SummaryRow({
    required this.icon,
    required this.label,
    this.value,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final value = this.value;
    final note = this.note;

    return ListTile(
      leading: Icon(icon, color: palette.accent),
      title: Text(label, style: textTheme.bodyLarge),
      subtitle: note == null
          ? null
          : Text(
              note,
              style: textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
      trailing: value == null
          ? null
          : Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final DeleteAllDataState state;
  final VoidCallback onDelete;

  const _DeleteButton({required this.state, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final deleteDataT = t.settings.deleteData;
    final deleting = state.status == DeleteAllDataStatus.deleting;
    final colors = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: context.palette.expense,
        foregroundColor: colors.onError,
      ),
      onPressed: state.canDelete ? onDelete : null,
      icon: deleting
          ? SizedBox.square(
              dimension: AppSpacing.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.onError,
              ),
            )
          : const Icon(PiconsRegular.trash),
      label: Text(deleting ? deleteDataT.deleting : deleteDataT.button),
    );
  }
}
