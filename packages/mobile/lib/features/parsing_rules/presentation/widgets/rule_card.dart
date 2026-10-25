import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:picons/picons.dart';
import '../../domain/entities/parsing_rule.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

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
      SourceType.sms => PiconsRegular.chatText,
      SourceType.email => PiconsRegular.envelope,
      SourceType.both => PiconsRegular.arrowsClockwise,
    };
  }

  String _getSourceLabel() => rule.sourceType.displayName;

  String _getTriggerWordsPreview() {
    final words = rule.triggerWords.join(', ');
    if (words.length <= 30) return words;

    return '${words.substring(0, 30)}...';
  }

  Container _buildDismissBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.md),
      color: theme.colorScheme.error,
      child: Icon(PiconsRegular.trash, color: theme.colorScheme.onError),
    );
  }

  AlertDialog _buildDeleteDialog(BuildContext context) {
    final strings = t.parsingRules.delete;

    return AlertDialog(
      title: Text(strings.title),
      content: Text(strings.confirm(name: rule.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.common.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(t.common.delete),
        ),
      ],
    );
  }

  Card _buildCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
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
        // Its own label: a tap on the card opens the rule instead.
        trailing: Semantics(
          label: rule.name,
          child: Switch(value: rule.isEnabled, onChanged: onToggle),
        ),
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
