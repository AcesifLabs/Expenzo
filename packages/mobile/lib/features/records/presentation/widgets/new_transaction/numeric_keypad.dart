import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'keypad_button.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class NumericKeypad extends StatefulWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final ColorScheme color;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.color,
  });

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  Timer? _backspaceTimer;
  Timer? _initialDelayTimer;

  static TextStyle _keypadTextStyle(Color color) =>
      AppTypography.headlineSmall.copyWith(color: color);

  void _cancelBackspaceTimers() {
    _initialDelayTimer?.cancel();
    _initialDelayTimer = null;
    _backspaceTimer?.cancel();
    _backspaceTimer = null;
  }

  void _onInitialDelayComplete() {
    _backspaceTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => widget.onBackspace(),
    );
  }

  void _onBackspaceLongPressStart(LongPressStartDetails _) {
    _cancelBackspaceTimers();
    widget.onBackspace();
    _initialDelayTimer = Timer(
      const Duration(milliseconds: 300),
      _onInitialDelayComplete,
    );
  }

  void _onBackspaceLongPressEnd(LongPressEndDetails _) {
    _cancelBackspaceTimers();
  }

  Widget _buildKeypadRow(List<Widget> buttons) {
    return Row(
      children: [
        for (var index = 0; index < buttons.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.xs),
          buttons[index],
        ],
      ],
    );
  }

  KeypadButton _buildDigitButton(
    String digit,
    TextStyle style,
    Color btnColor,
  ) {
    return KeypadButton(
      color: btnColor,
      height: 48,
      radius: AppSpacing.radiusControl,
      onTap: () => widget.onDigit(digit),
      child: Text(digit, style: style),
    );
  }

  KeypadButton _buildDecimalButton(TextStyle style, Color btnColor) {
    return KeypadButton(
      color: btnColor,
      height: 48,
      radius: AppSpacing.radiusControl,
      semanticLabel: t.records.sheet.decimalKey,
      onTap: () => widget.onDigit('.'),
      child: Text(CurrencyFormatter.decimalSeparator, style: style),
    );
  }

  KeypadButton _buildBackspaceButton(Color btnColor, Color txtColor) {
    return KeypadButton(
      color: btnColor,
      height: 48,
      radius: AppSpacing.radiusControl,
      semanticLabel: t.records.sheet.backspace,
      onTap: widget.onBackspace,
      onLongPressStart: _onBackspaceLongPressStart,
      onLongPressEnd: _onBackspaceLongPressEnd,
      onLongPressCancel: _cancelBackspaceTimers,
      child: Icon(PiconsRegular.backspace, color: txtColor, size: 20),
    );
  }

  @override
  void dispose() {
    _cancelBackspaceTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final btnColor = palette.surfaceHigh;
    final backspaceColor = palette.surfaceHigh;
    final txtColor = widget.color.onSurface;
    final style = _keypadTextStyle(txtColor);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          _buildKeypadRow([
            _buildDigitButton('1', style, btnColor),
            _buildDigitButton('2', style, btnColor),
            _buildDigitButton('3', style, btnColor),
          ]),
          const SizedBox(height: AppSpacing.xs),
          _buildKeypadRow([
            _buildDigitButton('4', style, btnColor),
            _buildDigitButton('5', style, btnColor),
            _buildDigitButton('6', style, btnColor),
          ]),
          const SizedBox(height: AppSpacing.xs),
          _buildKeypadRow([
            _buildDigitButton('7', style, btnColor),
            _buildDigitButton('8', style, btnColor),
            _buildDigitButton('9', style, btnColor),
          ]),
          const SizedBox(height: AppSpacing.xs),
          _buildKeypadRow([
            _buildDecimalButton(style, btnColor),
            _buildDigitButton('0', style, btnColor),
            _buildBackspaceButton(backspaceColor, txtColor),
          ]),
        ],
      ),
    );
  }
}
