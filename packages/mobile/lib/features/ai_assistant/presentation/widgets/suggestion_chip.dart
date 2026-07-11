import 'package:flutter/material.dart';

class SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SuggestionChip({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF201F21),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x50D1C4E9), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 13,
            color: Color(0xFFD1C4E9),
          ),
        ),
      ),
    );
  }
}
