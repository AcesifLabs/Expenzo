import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class RetroactiveScanDialog extends StatefulWidget {
  final MessageSource source;
  final ExpenseTemplate template;

  const RetroactiveScanDialog({
    super.key,
    required this.source,
    required this.template,
  });

  @override
  State<RetroactiveScanDialog> createState() => _RetroactiveScanDialogState();
}

Future<void> showRetroactiveScanDialog(
  BuildContext context,
  MessageSource source,
  ExpenseTemplate template,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => RetroactiveScanDialog(source: source, template: template),
  );
}

class _RetroactiveScanDialogState extends State<RetroactiveScanDialog> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _runScan();
  }

  Future<void> _runScan() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = t.messageTemplates.retro;

    return AlertDialog(
      title: Text(strings.title),
      content: _isScanning
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text(strings.scanning),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PiconsRegular.checkCircle,
                  color: context.palette.income,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(strings.saved),
                const SizedBox(height: AppSpacing.sm),
                Text(strings.review, textAlign: TextAlign.center),
              ],
            ),
      actions: [
        if (!_isScanning)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.done),
          ),
      ],
    );
  }
}
