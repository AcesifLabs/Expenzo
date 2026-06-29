import 'package:flutter/material.dart';
import '../../domain/entities/parsing_rule.dart';

class RuleCard extends StatelessWidget {
  final ParsingRule rule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RuleCard({
    super.key,
    required this.rule,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getSourceIcon() {
    return switch (rule.sourceType) {
      SourceType.sms => Icons.sms,
      SourceType.email => Icons.email,
      SourceType.both => Icons.sync,
    };
  }

  String _getSourceLabel() {
    return switch (rule.sourceType) {
      SourceType.sms => 'SMS',
      SourceType.email => 'Email',
      SourceType.both => 'Both',
    };
  }

  String _getTriggerWordsPreview() {
    final words = rule.triggerWords.join(', ');
    if (words.length <= 30) return words;

    return '${words.substring(0, 30)}...';
  }

  Container _buildDismissBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      color: theme.colorScheme.error,
      child: Icon(Icons.delete, color: theme.colorScheme.onError),
    );
  }

  AlertDialog _buildDeleteDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Rule'),
      content: Text('Are you sure you want to delete "${rule.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Card _buildCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(_getSourceIcon())),
        title: Text(rule.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTriggerWordsPreview(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(_getSourceLabel(), style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Switch(value: rule.isEnabled, onChanged: onToggle),
        isThreeLine: true,
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _buildDeleteDialog(context),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(rule.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(theme),
      confirmDismiss: (_) => _confirmDismiss(context),
      onDismissed: (_) => onDelete(),
      child: _buildCard(theme),
    );
  }
}
