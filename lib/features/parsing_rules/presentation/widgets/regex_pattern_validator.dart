import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/regex_utils.dart';

class RegexPatternValidator extends StatelessWidget {
  final String pattern;

  const RegexPatternValidator({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    if (pattern.isEmpty) {
      return const SizedBox.shrink();
    }

    final validation = TimedRegex.validatePattern(pattern);

    if (validation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              validation,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class RegexValidatorIndicator extends StatefulWidget {
  final String pattern;

  const RegexValidatorIndicator({super.key, required this.pattern});

  @override
  State<RegexValidatorIndicator> createState() =>
      _RegexValidatorIndicatorState();
}

class _RegexValidatorIndicatorState extends State<RegexValidatorIndicator> {
  bool _isValid = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _validatePattern();
  }

  @override
  void didUpdateWidget(RegexValidatorIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pattern != widget.pattern) {
      _validatePattern();
    }
  }

  void _validatePattern() {
    if (widget.pattern.isEmpty) {
      setState(() {
        _isValid = true;
        _errorMessage = null;
      });
      return;
    }

    try {
      RegExp(widget.pattern);
      final warning = TimedRegex.validatePattern(widget.pattern);
      setState(() {
        _isValid = warning == null;
        _errorMessage = warning;
      });
    } catch (e) {
      setState(() {
        _isValid = false;
        _errorMessage = 'Invalid regex: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pattern.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!_isValid || _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(
              _isValid ? Icons.warning : Icons.error,
              color: _isValid ? Colors.orange : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _errorMessage ?? '',
                style: TextStyle(
                  color: _isValid ? Colors.orange : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 16),
        SizedBox(width: 4),
        Text(
          'Valid pattern',
          style: TextStyle(color: Colors.green, fontSize: 12),
        ),
      ],
    );
  }
}
