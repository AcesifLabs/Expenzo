import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/utils/regex_utils.dart';

class RegexTesterWidget extends StatefulWidget {
  final String pattern;
  final String? datePattern;
  final Function(ParsedTestResult) onResult;

  const RegexTesterWidget({
    super.key,
    required this.pattern,
    this.datePattern,
    required this.onResult,
  });

  @override
  State<RegexTesterWidget> createState() => _RegexTesterWidgetState();
}

class _RegexTesterWidgetState extends State<RegexTesterWidget> {
  final TextEditingController _sampleController = TextEditingController();
  Timer? _debounceTimer;
  ParsedTestResult? _result;

  @override
  void dispose() {
    _sampleController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSampleChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _testPattern(value);
    });
  }

  void _testPattern(String sample) {
    if (widget.pattern.isEmpty || sample.isEmpty) {
      setState(() {
        _result = null;
      });
      return;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final timedRegex = TimedRegex(
        pattern: widget.pattern,
        timeout: const Duration(seconds: 2),
      );

      final match = timedRegex.firstMatch(sample);
      stopwatch.stop();

      double? extractedAmount;
      DateTime? extractedDate;

      if (match != null) {
        final amountStr = match.group(1) ?? match.group(0);
        if (amountStr != null) {
          final cleanAmount = amountStr.replaceAll(RegExp(r'[^\d.]'), '');
          extractedAmount = double.tryParse(cleanAmount);
        }
      }

      if (widget.datePattern != null && widget.datePattern!.isNotEmpty) {
        final dateRegex = TimedRegex(
          pattern: widget.datePattern!,
          timeout: const Duration(seconds: 2),
        );
        final dateMatch = dateRegex.firstMatch(sample);
        if (dateMatch != null) {
          extractedDate = _parseDate(dateMatch.group(0) ?? '');
        }
      }

      double confidence = 0.7;
      if (extractedAmount != null && extractedDate != null) {
        confidence = 1.0;
      } else if (extractedAmount != null) {
        confidence = 0.9;
      }

      final result = ParsedTestResult(
        amount: extractedAmount,
        date: extractedDate,
        elapsedMs: stopwatch.elapsedMilliseconds,
        timedOut: false,
        confidence: confidence,
        matchFound: match != null,
        sampleText: sample,
      );

      setState(() {
        _result = result;
      });
      widget.onResult(result);
    } catch (e) {
      stopwatch.stop();
      final result = ParsedTestResult(
        amount: null,
        date: null,
        elapsedMs: stopwatch.elapsedMilliseconds,
        timedOut: true,
        confidence: 0,
        matchFound: false,
        error: e.toString(),
        sampleText: sample,
      );
      setState(() {
        _result = result;
      });
      widget.onResult(result);
    }
  }

  DateTime? _parseDate(String dateStr) {
    final patterns = [
      RegExp(r'(\d{2})/(\d{2})/(\d{4})'),
      RegExp(r'(\d{2})-(\d{2})-(\d{4})'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(dateStr);
      if (match != null) {
        try {
          final month = int.parse(match.group(1)!);
          final day = int.parse(match.group(2)!);
          final year = int.parse(match.group(3)!);
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _sampleController,
          decoration: const InputDecoration(
            labelText: 'Sample message to test',
            hintText: 'Enter a sample SMS or email text',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: _onSampleChanged,
        ),
        const SizedBox(height: 16),
        if (_result != null) ...[
          _buildResultCard(),
        ] else ...[
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Enter a sample message above to test the pattern',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultCard() {
    final result = _result!;

    if (result.timedOut) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(PhosphorIcons.warning(PhosphorIconsStyle.regular), color: Colors.orange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '⏱️ Timeout - Pattern took more than 2 seconds',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (result.error != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.regular), color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(result.error!),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.matchFound ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                  color: result.matchFound ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  result.matchFound ? 'Match found' : 'No match',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: result.matchFound ? Colors.green : Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  '⏱️ ${result.elapsedMs}ms',
                  style: TextStyle(
                    color: result.elapsedMs > 1000
                        ? Colors.orange
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (result.matchFound) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFieldResult('Amount', result.amount?.toString()),
                  const SizedBox(width: 16),
                  _buildFieldResult('Date', result.date?.toString()),
                  const Spacer(),
                  Text('${(result.confidence * 100).toInt()}% confidence'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFieldResult(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value ?? '-',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: value != null ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class ParsedTestResult {
  final double? amount;
  final DateTime? date;
  final int elapsedMs;
  final bool timedOut;
  final double confidence;
  final bool matchFound;
  final String? error;
  final String sampleText;

  ParsedTestResult({
    this.amount,
    this.date,
    required this.elapsedMs,
    required this.timedOut,
    required this.confidence,
    required this.matchFound,
    this.error,
    required this.sampleText,
  });
}
