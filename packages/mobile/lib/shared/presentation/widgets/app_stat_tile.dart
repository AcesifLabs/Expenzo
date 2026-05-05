import 'package:flutter/material.dart';

/// Standardized stats/insight tile with icon, label, value, and optional subtitle.
///
/// Usage:
/// ```dart
/// AppStatTile(
///   icon: PhosphorIcons.trendUp(PhosphorIconsStyle.regular),
///   title: 'Highest Spending Day',
///   value: '\$450.00',
///   subtitle: 'In selected period',
///   color: Colors.orange,
/// )
/// ```
class AppStatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const AppStatTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(50),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
