import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import '../helpers/sms_scan_range_presets.dart';
import '../models/sms_scan_range_preset.dart';
import '../models/sms_scan_range_selection.dart';

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
        label: 'Custom Range',
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Select date';
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[value.month - 1]} ${value.day}, ${value.year}';
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
      title: const Text('Select custom range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a start and end date before scanning past SMS for records.',
            style: TextStyle(color: colors.onSurface.withAlpha(180)),
          ),
          const SizedBox(height: 16),
          _DateField(
            key: const Key('scan_range_start_field'),
            label: 'Start date',
            value: _formatDate(_startDate),
            onTap: () => unawaited(_pickStartDate()),
          ),
          const SizedBox(height: 10),
          _DateField(
            key: const Key('scan_range_end_field'),
            label: 'End date',
            value: _formatDate(_endDate),
            onTap: () => unawaited(_pickEndDate()),
          ),
          if (!validRange) ...[
            const SizedBox(height: 12),
            Text(
              'Pick a valid start and end date.',
              key: const Key('scan_range_validation_message'),
              style: TextStyle(color: colors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('scan_range_apply_button'),
          onPressed: validRange ? _apply : null,
          child: const Text('Apply Range'),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(height: 2),
                  Text(value),
                ],
              ),
            ),
            Icon(PiconsRegular.calendar),
          ],
        ),
      ),
    );
  }
}
