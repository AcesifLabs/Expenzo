import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/regex_utils.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

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

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        border: Border.all(color: colorScheme.tertiary),
      ),
      child: Row(
        children: [
          Icon(PiconsRegular.warning, color: colorScheme.tertiary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              validation,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.tertiary,
              ),
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
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      setState(() {
        _isValid = false;
        _errorMessage = t.parsingRules.validation.invalidRegexDetail(
          detail: e.toString(),
        );
      });
    }
  }

  @override
  void didUpdateWidget(RegexValidatorIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pattern != widget.pattern) {
      _validatePattern();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pattern.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    if (!_isValid || _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              _isValid ? PiconsRegular.warning : PiconsRegular.warningCircle,
              color: _isValid ? colorScheme.tertiary : colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                _errorMessage ?? '',
                style: AppTypography.bodySmall.copyWith(
                  color: _isValid ? colorScheme.tertiary : colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final validColor = context.palette.income;

    return Row(
      children: [
        Icon(PiconsRegular.checkCircle, color: validColor, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Text(
          t.parsingRules.validation.valid,
          style: AppTypography.bodySmall.copyWith(color: validColor),
        ),
      ],
    );
  }
}
