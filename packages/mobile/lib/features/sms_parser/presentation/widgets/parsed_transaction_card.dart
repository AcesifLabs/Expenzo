import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_badge.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

class ParsedTransactionCard extends StatelessWidget {
  final ParsedTransaction transaction;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  const ParsedTransactionCard({
    super.key,
    required this.transaction,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return AppCard(
      onTap: () => onSelectionChanged(!isSelected),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) => onSelectionChanged(value ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.amount != null
                          ? currencyFormat.format(transaction.amount)
                          : 'N/A',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: transaction.amount != null
                            ? theme.colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppBadge(
                      label: 'SMS',
                      icon: PhosphorIcons.chat(PhosphorIconsStyle.regular),
                      size: AppBadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.rawMessage.length > 50
                      ? '${transaction.rawMessage.substring(0, 50)}...'
                      : transaction.rawMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (transaction.matchedRuleId != null) ...[
                      AppBadge(
                        label: 'Rule: ${transaction.matchedRuleId}',
                        size: AppBadgeSize.small,
                      ),
                      const SizedBox(width: 8),
                    ],
                    AppBadge(
                      label: '${(transaction.confidenceScore * 100).toInt()}%',
                      size: AppBadgeSize.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
