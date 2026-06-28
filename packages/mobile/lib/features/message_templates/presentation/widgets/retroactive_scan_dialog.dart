import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';

class RetroactiveScanDialog extends StatefulWidget {
  final MessageSource source;
  final ExpenseTemplate template;

  const RetroactiveScanDialog({
    super.key,
    required this.source,
    required this.template,
  });

  static Future<void> show(
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

  @override
  State<RetroactiveScanDialog> createState() => _RetroactiveScanDialogState();
}

class _RetroactiveScanDialogState extends State<RetroactiveScanDialog> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _runScan();
  }

  Future<void> _runScan() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scanning Past Messages'),
      content: _isScanning
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Looking for past expenses matching your new template...'),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PiconsFill.checkCircle, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text(
                  'Template active! Future messages will be parsed automatically.',
                ),
                SizedBox(height: 8),
                Text(
                  'Go to the Scan tab to review and create any past expenses we found.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
      actions: [
        if (!_isScanning)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
      ],
    );
  }
}
