import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import '../../../parsing_rules/presentation/widgets/confidence_badge.dart';

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
    final currencyFormat = NumberFormat.currency(symbol: '৳');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onSelectionChanged(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
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
                        const Icon(
                          LucideIcons.messageSquare,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('SMS', style: theme.textTheme.bodySmall),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Rule: ${transaction.matchedRuleId}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ConfidenceBadge(
                          confidenceScore: transaction.confidenceScore,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
