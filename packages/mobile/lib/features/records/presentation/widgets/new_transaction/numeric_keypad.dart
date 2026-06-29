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
      TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: color);

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
    return Row(children: buttons);
  }

  KeypadButton _buildDigitButton(
    String digit,
    TextStyle style,
    Color btnColor,
  ) {
    return KeypadButton(
      color: btnColor,
      onTap: () => widget.onDigit(digit),
      child: Text(digit, style: style),
    );
  }

  KeypadButton _buildBackspaceButton(Color btnColor, Color txtColor) {
    return KeypadButton(
      color: btnColor,
      onTap: widget.onBackspace,
      onLongPressStart: _onBackspaceLongPressStart,
      onLongPressEnd: _onBackspaceLongPressEnd,
      onLongPressCancel: _cancelBackspaceTimers,
      child: Icon(PiconsLight.backspace, color: txtColor, size: 22),
    );
  }

  @override
  void dispose() {
    _cancelBackspaceTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.color.onSurface.withAlpha(12);
    final txtColor = widget.color.onSurface;
    final style = _keypadTextStyle(txtColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildKeypadRow([
            _buildDigitButton('1', style, btnColor),
            _buildDigitButton('2', style, btnColor),
            _buildDigitButton('3', style, btnColor),
          ]),
          _buildKeypadRow([
            _buildDigitButton('4', style, btnColor),
            _buildDigitButton('5', style, btnColor),
            _buildDigitButton('6', style, btnColor),
          ]),
          _buildKeypadRow([
            _buildDigitButton('7', style, btnColor),
            _buildDigitButton('8', style, btnColor),
            _buildDigitButton('9', style, btnColor),
          ]),
          _buildKeypadRow([
            _buildDigitButton('.', style, btnColor),
            _buildDigitButton('0', style, btnColor),
            _buildBackspaceButton(btnColor, txtColor),
          ]),
        ],
      ),
    );
  }
}
