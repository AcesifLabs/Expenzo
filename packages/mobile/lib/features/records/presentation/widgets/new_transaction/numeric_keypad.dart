import 'dart:async';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'keypad_button.dart';

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
      TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: color);

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
          if (index > 0) const SizedBox(width: 2),
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
      radius: 8,
      onTap: () => widget.onDigit(digit),
      child: Text(digit, style: style),
    );
  }

  KeypadButton _buildBackspaceButton(Color btnColor, Color txtColor) {
    return KeypadButton(
      color: btnColor,
      height: 48,
      radius: 8,
      semanticLabel: 'Backspace',
      onTap: widget.onBackspace,
      onLongPressStart: _onBackspaceLongPressStart,
      onLongPressEnd: _onBackspaceLongPressEnd,
      onLongPressCancel: _cancelBackspaceTimers,
      child: Icon(PiconsLight.backspace, color: txtColor, size: 20),
    );
  }

  @override
  void dispose() {
    _cancelBackspaceTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const btnColor = Color(0xFF201F21);
    const backspaceColor = Color(0xFF2B292C);
    final txtColor = widget.color.onSurface;
    final style = _keypadTextStyle(txtColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          _buildKeypadRow([
            _buildDigitButton('1', style, btnColor),
            _buildDigitButton('2', style, btnColor),
            _buildDigitButton('3', style, btnColor),
          ]),
          const SizedBox(height: 2),
          _buildKeypadRow([
            _buildDigitButton('4', style, btnColor),
            _buildDigitButton('5', style, btnColor),
            _buildDigitButton('6', style, btnColor),
          ]),
          const SizedBox(height: 2),
          _buildKeypadRow([
            _buildDigitButton('7', style, btnColor),
            _buildDigitButton('8', style, btnColor),
            _buildDigitButton('9', style, btnColor),
          ]),
          const SizedBox(height: 2),
          _buildKeypadRow([
            _buildDigitButton('.', style, btnColor),
            _buildDigitButton('0', style, btnColor),
            _buildBackspaceButton(backspaceColor, txtColor),
          ]),
        ],
      ),
    );
  }
}
