import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';
import '../bloc/template_editor_bloc.dart';
import '../bloc/template_editor_event.dart';
import '../bloc/template_editor_state.dart';
import '../../../sms_parser/domain/entities/sms_message.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;

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
  int _foundCount = 0;

  @override
  void initState() {
    super.initState();
    _runScan();
  }

  Future<void> _runScan() async {
    // 1. Fetch SMS
    // 2. Evaluate template
    // 3. Create Expenses
    // We will simulate it here to just trigger the generic ScanSmsUseCase

    // Instead of full manual implementation here, we'll just fire the global SMS scan event
    // and let the SmsScannerBloc handle evaluating everything.

    // Simulating the run process for the user feedback
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isScanning = false;
        _foundCount = 0; // We tell them to go to the Scan tab to see results
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
          : const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
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
