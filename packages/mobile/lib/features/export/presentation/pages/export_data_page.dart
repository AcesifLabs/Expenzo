import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_section.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/helpers/resolve_export_period.dart';
import '../../domain/entities/export_request.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

class ExportDataPage extends StatelessWidget {
  const ExportDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<ExportBloc>(),
      child: const Scaffold(body: ExportDataView()),
    );
  }
}

/// Exports transactions, budgets and categories as CSV and opens the share
/// sheet. The design's FORMAT section is cut: CSV is the only format
/// (docs/adr/0011).
class ExportDataView extends StatelessWidget {
  /// Replaceable in tests, to pin the range subtitles and picker bounds.
  final DateTime Function() clock;

  const ExportDataView({super.key, this.clock = DateTime.now});

  /// A getter, as a `DateFormat` keeps the language it was created in.
  static DateFormat get _dateFormat => DateFormat.yMMMd();

  IconData _contentIcon(ExportContent content) => switch (content) {
    ExportContent.transactions => PiconsRegular.receipt,
    ExportContent.budgets => PiconsRegular.wallet,
    ExportContent.categories => PiconsRegular.tag,
  };

  String _contentTitle(ExportContent content) {
    final includeT = t.settings.export.include;

    return switch (content) {
      ExportContent.transactions => includeT.transactions,
      ExportContent.budgets => includeT.budgets,
      ExportContent.categories => includeT.categories,
    };
  }

  bool _failedNow(ExportState previous, ExportState current) =>
      current.status == ExportStatus.failed &&
      previous.status != ExportStatus.failed;

  void _showFailure(BuildContext context, ExportState state) {
    final message = state.errorMessage;
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildBody(BuildContext context, ExportState state) {
    final exportT = t.settings.export;
    final palette = context.palette;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.pagePadding,
            children: [
              const _InfoCard(),
              _rangeSection(context, state),
              _includeSection(context, state),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  exportT.rangeNote,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
                ),
              ),
            ],
          ),
        ),
        _ExportFooter(state: state, onExport: () => _onExport(context)),
      ],
    );
  }

  Widget _rangeSection(BuildContext context, ExportState state) {
    final format = _dateFormat;

    return SettingsSection(
      title: t.settings.export.sections.dateRange,
      children: [
        for (final range in ExportRange.values)
          SettingsChoiceTile(
            title: _rangeTitle(range),
            subtitle: _rangeSubtitle(range, state, format),
            selected: state.range == range,
            enabled: !state.isExporting,
            onTap: () => _onRangeTap(context, range, state),
          ),
      ],
    );
  }

  Widget _includeSection(BuildContext context, ExportState state) {
    return SettingsSection(
      title: t.settings.export.sections.include,
      children: [
        for (final content in ExportContent.values)
          SettingsSwitchTile(
            icon: _contentIcon(content),
            title: _contentTitle(content),
            value: state.contents.contains(content),
            onChanged: state.isExporting
                ? null
                : (included) =>
                      _onContentToggled(context, content, included: included),
          ),
      ],
    );
  }

  String _rangeTitle(ExportRange range) {
    final rangesT = t.settings.export.ranges;

    return switch (range) {
      ExportRange.allTime => rangesT.allTime,
      ExportRange.thisYear => rangesT.thisYear,
      ExportRange.lastSixMonths => rangesT.lastSixMonths,
      ExportRange.lastThreeMonths => rangesT.lastThreeMonths,
      ExportRange.custom => rangesT.custom,
    };
  }

  String _rangeSubtitle(
    ExportRange range,
    ExportState state,
    DateFormat format,
  ) {
    final rangesT = t.settings.export.ranges;

    return switch (range) {
      ExportRange.allTime => rangesT.allTimeSubtitle,
      ExportRange.custom => switch ((state.customStart, state.customEnd)) {
        (final start?, final end?) => rangesT.between(
          start: format.format(start),
          end: format.format(end),
        ),
        _ => rangesT.customSubtitle,
      },
      _ => rangesT.untilToday(start: format.format(_presetStart(range))),
    };
  }

  /// The first day a preset range covers, from the same maths the export
  /// uses.
  DateTime _presetStart(ExportRange range) {
    final now = clock();
    final request = ExportRequest(
      range: range,
      contents: const {ExportContent.transactions},
    );

    return resolveExportPeriod(request, now).start ?? now;
  }

  void _onRangeTap(BuildContext context, ExportRange range, ExportState state) {
    if (range == ExportRange.custom) {
      _pickCustomRange(context, state);

      return;
    }
    context.read<ExportBloc>().add(ExportRangeSelected(range));
  }

  /// Custom is only selected once the user confirms a range; cancelling
  /// keeps the previous choice. Tapping it again re-opens the picker.
  Future<void> _pickCustomRange(BuildContext context, ExportState state) async {
    final bloc = context.read<ExportBloc>();
    final now = clock();
    final initial = switch ((state.customStart, state.customEnd)) {
      (final start?, final end?) => DateTimeRange(start: start, end: end),
      _ => null,
    };
    final picked = await showDateRangePicker(
      context: context,
      firstDate: AppConstants.pickerFirstDate,
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: initial,
    );
    if (picked == null) return;
    bloc.add(ExportCustomRangePicked(picked.start, picked.end));
  }

  void _onContentToggled(
    BuildContext context,
    ExportContent content, {
    required bool included,
  }) {
    context.read<ExportBloc>().add(
      ExportContentToggled(content, included: included),
    );
  }

  void _onExport(BuildContext context) {
    context.read<ExportBloc>().add(const ExportRequested());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.export.title,
      leading: const AppBackButton(),
      child: BlocConsumer<ExportBloc, ExportState>(
        listenWhen: _failedNow,
        listener: _showFailure,
        builder: _buildBody,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final exportT = t.settings.export;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      backgroundColor: palette.surfaceHigh,
      borderRadius: AppSpacing.radiusCard,
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PiconsRegular.export, color: palette.accent),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exportT.infoTitle, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  exportT.infoBody,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
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

/// The Export button, pinned under the list, with the empty-range and
/// nothing-selected messages.
class _ExportFooter extends StatelessWidget {
  final ExportState state;
  final VoidCallback onExport;

  const _ExportFooter({required this.state, required this.onExport});

  @override
  Widget build(BuildContext context) {
    final exportT = t.settings.export;
    final hintStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: context.palette.textSecondary);
    final exporting = state.isExporting;
    final emptyMessage = state.status == ExportStatus.empty
        ? state.errorMessage
        : null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.sm,
          AppSpacing.pageGutter,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (emptyMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  emptyMessage,
                  style: hintStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton.icon(
              onPressed: state.canExport ? onExport : null,
              icon: exporting
                  ? const SizedBox.square(
                      dimension: AppSpacing.iconSm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(PiconsRegular.export),
              label: Text(exporting ? exportT.exporting : exportT.button),
            ),
            if (state.contents.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  exportT.nothingSelected,
                  style: hintStyle,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
