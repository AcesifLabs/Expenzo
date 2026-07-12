import 'package:flutter/material.dart';

class KeypadButton extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;
  final double height;
  final double radius;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final VoidCallback? onLongPressCancel;

  const KeypadButton({
    super.key,
    required this.color,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.height = 48,
    this.radius = 8,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onLongPressCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onLongPressStart: onLongPressStart,
        onLongPressEnd: onLongPressEnd,
        onLongPressCancel: onLongPressCancel,
        child: Semantics(
          button: true,
          label: semanticLabel,
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: SizedBox(
                height: height,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
