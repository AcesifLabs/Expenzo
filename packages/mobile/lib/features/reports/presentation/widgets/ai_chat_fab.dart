import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

class AIChatFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const AIChatFAB({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFD1C4E9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Icon(PiconsRegular.robot, size: 24, color: Color(0xFF141315)),
        ),
      ),
    );
  }
}
