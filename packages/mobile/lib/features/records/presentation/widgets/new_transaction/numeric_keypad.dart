import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

  @override
  void dispose() {
    _cancelBackspaceTimers();
    super.dispose();
  }

  void _cancelBackspaceTimers() {
    _initialDelayTimer?.cancel();
    _initialDelayTimer = null;
    _backspaceTimer?.cancel();
    _backspaceTimer = null;
  }

  void _onBackspaceLongPressStart(LongPressStartDetails _) {
    _cancelBackspaceTimers();
    widget.onBackspace();
    _initialDelayTimer = Timer(const Duration(milliseconds: 300), () {
      _backspaceTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => widget.onBackspace(),
      );
    });
  }

  void _onBackspaceLongPressEnd(LongPressEndDetails _) {
    _cancelBackspaceTimers();
  }

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.color.onSurface.withAlpha(12);
    final txtColor = widget.color.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('1'),
                child: Text('1', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('2'),
                child: Text('2', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('3'),
                child: Text('3', style: _keypadTextStyle(txtColor)),
              ),
            ],
          ),
          Row(
            children: [
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('4'),
                child: Text('4', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('5'),
                child: Text('5', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('6'),
                child: Text('6', style: _keypadTextStyle(txtColor)),
              ),
            ],
          ),
          Row(
            children: [
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('7'),
                child: Text('7', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('8'),
                child: Text('8', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('9'),
                child: Text('9', style: _keypadTextStyle(txtColor)),
              ),
            ],
          ),
          Row(
            children: [
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('.'),
                child: Text('.', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: () => widget.onDigit('0'),
                child: Text('0', style: _keypadTextStyle(txtColor)),
              ),
              KeypadButton(
                color: btnColor,
                onTap: widget.onBackspace,
                onLongPressStart: _onBackspaceLongPressStart,
                onLongPressEnd: _onBackspaceLongPressEnd,
                onLongPressCancel: _cancelBackspaceTimers,
                child: Icon(
                  PhosphorIcons.backspace(PhosphorIconsStyle.light),
                  color: txtColor,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static TextStyle _keypadTextStyle(Color color) =>
      TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: color);
}