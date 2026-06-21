import 'package:flutter/material.dart';

class MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final IconData? trailing;

  const MenuRow({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        if (trailing != null) Icon(trailing, size: 18),
      ],
    );
  }
}