import 'dart:async';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
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
  String _pendingSample = '';

  @override
  void initState() {
    super.initState();
  }

  void _onSampleChanged(String value) {
    _pendingSample = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      _onDebounceElapsed,
    );
  }

  void _onDebounceElapsed() {
    _testPattern(_pendingSample);
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
      _runPatternTest(sample, stopwatch);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      _handlePatternError(sample, stopwatch, e);
    }
  }

  void _runPatternTest(String sample, Stopwatch stopwatch) {
    final timedRegex = TimedRegex(
      pattern: widget.pattern,
      timeout: const Duration(seconds: 2),
    );

    final match = timedRegex.firstMatch(sample);
    stopwatch.stop();

    final extractedAmount = _extractAmount(match);
    final extractedDate = _extractDate(sample);
    final confidence = _computeConfidence(extractedAmount, extractedDate);

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
  }

  double? _extractAmount(Match? match) {
    if (match == null) return null;

    final amountStr = match.group(1) ?? match.group(0);
    if (amountStr == null) return null;

    final cleanAmount = amountStr.replaceAll(RegExp(r'[^\d.]'), '');

    return double.tryParse(cleanAmount);
  }

  DateTime? _extractDate(String sample) {
    final datePattern = widget.datePattern;
    if (datePattern == null || datePattern.isEmpty) return null;

    final dateRegex = TimedRegex(
      pattern: datePattern,
      timeout: const Duration(seconds: 2),
    );
    final dateMatch = dateRegex.firstMatch(sample);
    if (dateMatch == null) return null;

    return _parseDate(dateMatch.group(0) ?? '');
  }

  double _computeConfidence(double? amount, DateTime? date) {
    if (amount != null && date != null) return 1.0;
    if (amount != null) return 0.9;

    return 0.7;
  }

  void _handlePatternError(String sample, Stopwatch stopwatch, Object e) {
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

  DateTime? _parseDate(String dateStr) {
    final patterns = [
      RegExp(r'(\d{2})/(\d{2})/(\d{4})'),
      RegExp(r'(\d{2})-(\d{2})-(\d{4})'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(dateStr);
      if (match != null) {
        try {
          final month = _intFromGroup(match, 1);
          final day = _intFromGroup(match, 2);
          final year = _intFromGroup(match, 3);
          if (month == null || day == null || year == null) continue;

          return DateTime(year, month, day);
        } catch (e, s) {
          debugPrint('Error: $e\n$s');
          debugPrint('RegexTesterWidget: Failed to parse date components: $e');
        }
      }
    }

    return null;
  }

  int? _intFromGroup(RegExpMatch match, int group) {
    final value = match.group(group);
    if (value == null) return null;

    return int.tryParse(value);
  }

  Widget _buildResultCard() {
    final result = _result;
    if (result == null) return const SizedBox.shrink();

    if (result.timedOut) {
      return _buildTimeoutCard();
    }

    final error = result.error;
    if (error != null) {
      return _buildErrorCard(error);
    }

    return _buildSuccessCard(result);
  }

  Card _buildTimeoutCard() {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.tertiaryContainer,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(PiconsRegular.warning, color: colors.tertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '⏱️ Timeout - Pattern took more than 2 seconds',
                style: TextStyle(color: colors.tertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildErrorCard(String error) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PiconsRegular.warningCircle, color: colors.error),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: TextStyle(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(error),
          ],
        ),
      ),
    );
  }

  Card _buildSuccessCard(ParsedTestResult result) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(result),
            if (result.matchFound) ...[
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailsRow(result),
            ],
          ],
        ),
      ),
    );
  }

  Row _buildHeaderRow(ParsedTestResult result) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          result.matchFound ? PiconsFill.checkCircle : PiconsFill.xCircle,
          color: result.matchFound ? colors.secondary : colors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          result.matchFound ? 'Match found' : 'No match',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: result.matchFound
                ? colors.secondary
                : colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          '⏱️ ${result.elapsedMs}ms',
          style: TextStyle(
            color: result.elapsedMs > 1000
                ? colors.tertiary
                : colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Row _buildDetailsRow(ParsedTestResult result) {
    return Row(
      children: [
        _buildFieldResult('Amount', result.amount?.toString()),
        const SizedBox(width: 16),
        _buildFieldResult('Date', result.date?.toString()),
        const Spacer(),
        Text('${(result.confidence * 100).toInt()}% confidence'),
      ],
    );
  }

  Widget _buildFieldResult(String label, String? value) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
        ),
        Text(
          value ?? '-',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: value != null ? colors.secondary : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sampleController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
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
          Card(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Text(
                'Enter a sample message above to test the pattern',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
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
