import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../helpers/sms_scan_range_presets.dart';
import '../models/sms_scan_range_preset.dart';
import '../models/sms_scan_range_selection.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

typedef SmsScanDatePicker =
    Future<DateTime?> Function(BuildContext context, DateTime initialDate);

class SmsScanDateRangeDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final SmsScanDatePicker? datePicker;

  const SmsScanDateRangeDialog({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.datePicker,
  });

  @override
  State<SmsScanDateRangeDialog> createState() => _SmsScanDateRangeDialogState();
}

class _SmsScanDateRangeDialogState extends State<SmsScanDateRangeDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _pickStartDate() async {
    final picked = await _showPicker(_startDate ?? DateTime.now());
    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _startDate = picked;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await _showPicker(_endDate ?? _startDate ?? DateTime.now());
    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _endDate = picked;
    });
  }

  Future<DateTime?> _showPicker(DateTime initialDate) {
    final picker = widget.datePicker;
    if (picker != null) {
      return picker(context, initialDate);
    }

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
  }

  void _apply() {
    if (!isValidCustomScanRange(startDate: _startDate, endDate: _endDate)) {
      return;
    }

    Navigator.of(context).pop(
      SmsScanRangeSelection(
        preset: SmsScanRangePreset.custom,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return t.smsParser.range.selectDate;

    return DateFormat.yMMMd().format(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final validRange = isValidCustomScanRange(
      startDate: _startDate,
      endDate: _endDate,
    );

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(t.smsParser.customRange.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.smsParser.customRange.body,
            style: TextStyle(color: colors.onSurface.withAlpha(180)),
          ),
          const SizedBox(height: AppSpacing.md),
          _DateField(
            key: const Key('scan_range_start_field'),
            label: t.smsParser.customRange.start,
            value: _formatDate(_startDate),
            onTap: () => unawaited(_pickStartDate()),
          ),
          const SizedBox(height: AppSpacing.smd),
          _DateField(
            key: const Key('scan_range_end_field'),
            label: t.smsParser.customRange.end,
            value: _formatDate(_endDate),
            onTap: () => unawaited(_pickEndDate()),
          ),
          if (!validRange) ...[
            const SizedBox(height: AppSpacing.smd),
            Text(
              t.smsParser.customRange.invalid,
              key: const Key('scan_range_validation_message'),
              style: TextStyle(color: colors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        FilledButton(
          key: const Key('scan_range_apply_button'),
          onPressed: validRange ? _apply : null,
          child: Text(t.smsParser.customRange.apply),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: colors.onSurface.withAlpha(160)),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value),
                ],
              ),
            ),
            const Icon(PiconsRegular.calendar),
          ],
        ),
      ),
    );
  }
}
