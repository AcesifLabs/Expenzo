import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

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

    return SafeArea(
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withAlpha(60),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Center(
                  child: Text(
                    'Scan past SMS for records',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              _ScanOptionTile(
                label: 'Last 7 Days',
                icon: PiconsRegular.clockCounterClockwise,
                onTap: () =>
                    _selectPreset(context, SmsScanRangePreset.last7Days),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: 'Last 30 Days',
                icon: PiconsRegular.calendar,
                onTap: () =>
                    _selectPreset(context, SmsScanRangePreset.last30Days),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: 'Last 3 Months',
                icon: PiconsRegular.calendarBlank,
                onTap: () =>
                    _selectPreset(context, SmsScanRangePreset.last3Months),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: 'All Time',
                icon: PiconsRegular.infinity,
                onTap: () => _selectPreset(context, SmsScanRangePreset.allTime),
              ),
              const Divider(height: 1),
              _ScanOptionTile(
                label: 'Custom date range',
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
