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
    switch (rule.sourceType) {
      case SourceType.sms:
        return Icons.sms;
      case SourceType.email:
        return Icons.email;
      case SourceType.both:
        return Icons.sync;
    }
  }

  String _getSourceLabel() {
    switch (rule.sourceType) {
      case SourceType.sms:
        return 'SMS';
      case SourceType.email:
        return 'Email';
      case SourceType.both:
        return 'Both';
    }
  }

  String _getTriggerWordsPreview() {
    final words = rule.triggerWords.join(', ');
    if (words.length <= 30) return words;
    return '${words.substring(0, 30)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(rule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Rule'),
                content: Text(
                  'Are you sure you want to delete "${rule.name}"?',
                ),
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
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
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
      ),
    );
  }
}
