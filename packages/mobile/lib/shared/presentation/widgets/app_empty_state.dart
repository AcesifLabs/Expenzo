import 'package:flutter/material.dart';

/// Unified empty state with icon and message.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const AppEmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: colors.onSurface.withAlpha(60)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}
