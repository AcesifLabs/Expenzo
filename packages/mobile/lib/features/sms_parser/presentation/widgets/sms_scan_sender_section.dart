import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

import '../models/sender_result_section.dart';
import 'parsed_transaction_card.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class SmsScanSenderSection extends StatelessWidget {
  final SenderResultSection section;
  final Set<String> selectedIds;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final ValueChanged<String> onToggleSelection;

  const SmsScanSenderSection({
    super.key,
    required this.section,
    required this.selectedIds,
    required this.onSelectAll,
    required this.onClear,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final itemCount = section.items.length;
    final selectedCount = section.items
        .where((item) => selectedIds.contains(item.sourceId))
        .length;
    final allSelected = selectedCount == itemCount;
    final sectionT = t.smsParser.section;
    final actionLabel = allSelected ? sectionT.clear : sectionT.selectAll;
    final actionColor = allSelected ? colors.primary : colors.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.senderLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sectionT.counts(n: itemCount, selected: selectedCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withAlpha(170),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              key: Key('sender_section_action_${section.senderKey}'),
              onPressed: allSelected ? onClear : onSelectAll,
              child: Text(actionLabel, style: TextStyle(color: actionColor)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...section.items.map(
          (item) => ParsedTransactionCard(
            transaction: item.parsedTransaction,
            isSelected: selectedIds.contains(item.sourceId),
            onSelectionChanged: (_) => onToggleSelection(item.sourceId),
          ),
        ),
      ],
    );
  }
}
