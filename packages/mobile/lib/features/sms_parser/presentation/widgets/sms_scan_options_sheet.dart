import 'package:flutter/material.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../helpers/sms_scan_range_presets.dart';
import '../models/sms_scan_range_preset.dart';
import '../models/sms_scan_range_selection.dart';
import 'sms_scan_date_range_dialog.dart';

class SmsScanOptionsSheet extends StatelessWidget {
  final DateTime now;
  final Future<SmsScanRangeSelection?> Function(BuildContext context)?
  customRangePicker;

  const SmsScanOptionsSheet({
    super.key,
    required this.now,
    this.customRangePicker,
  });

  Future<void> _selectPreset(
    BuildContext context,
    SmsScanRangePreset preset,
  ) async {
    if (preset == SmsScanRangePreset.custom) {
      final picker = customRangePicker ?? _showDefaultCustomRangePicker;
      final selection = await picker(context);
      if (!context.mounted || selection == null) {
        return;
      }

      Navigator.of(context).pop(selection);

      return;
    }

    Navigator.of(context).pop(buildPresetScanRange(preset: preset, now: now));
  }

  Future<SmsScanRangeSelection?> _showDefaultCustomRangePicker(
    BuildContext context,
  ) {
    return showDialog<SmsScanRangeSelection>(
      context: context,
      builder: (_) => const SmsScanDateRangeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rangeT = t.smsParser.range;

    return SafeArea(
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: AppSpacing.smd,
                  bottom: AppSpacing.sm,
                ),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withAlpha(60),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Center(
                  child: Text(
                    t.smsParser.options.title,
                    style: AppTypography.titleLarge,
                  ),
                ),
              ),
              _ScanOptionTile(
                label: rangeT.last7Days,
                icon: PiconsRegular.clockCounterClockwise,
                onTap: () =>
                    _selectPreset(context, SmsScanRangePreset.last7Days),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: rangeT.last30Days,
                icon: PiconsRegular.calendar,
                onTap: () =>
                    _selectPreset(context, SmsScanRangePreset.last30Days),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: rangeT.last3Months,
                icon: PiconsRegular.calendarBlank,
                onTap: () =>
                    _selectPreset(context, SmsScanRangePreset.last3Months),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: rangeT.allTime,
                icon: PiconsRegular.infinity,
                onTap: () => _selectPreset(context, SmsScanRangePreset.allTime),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: rangeT.custom,
                icon: PiconsRegular.calendarPlus,
                trailing: const Icon(PiconsRegular.caretRight),
                onTap: () => _selectPreset(context, SmsScanRangePreset.custom),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ScanOptionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colors.primary),
      title: Text(label),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
