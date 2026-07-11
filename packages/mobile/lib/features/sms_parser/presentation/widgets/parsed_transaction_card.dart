import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
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

  Widget _buildAmountRow(ThemeData theme, NumberFormat currencyFormat) {
    final amount = transaction.amount;
    final hasAmount = amount != null;
    final colors = theme.colorScheme;
    final amountColor = isSelected ? colors.primary : colors.onSurface;
    final badgeColor = isSelected
        ? colors.primary
        : colors.onSurface.withAlpha(180);

    return Row(
      children: [
        Text(
          hasAmount ? currencyFormat.format(amount) : 'N/A',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: hasAmount ? amountColor : Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        AppBadge(
          label: 'SMS',
          icon: PiconsRegular.chat,
          size: AppBadgeSize.small,
          color: badgeColor,
        ),
      ],
    );
  }

  Widget _buildBadgesRow(ThemeData theme) {
    final colors = theme.colorScheme;
    final badgeColor = isSelected
        ? colors.primary
        : colors.onSurface.withAlpha(180);

    return Row(
      children: [
        if (transaction.matchedRuleId != null) ...[
          AppBadge(
            label: 'Rule: ${transaction.matchedRuleId}',
            size: AppBadgeSize.small,
            color: colors.primary,
          ),
          const SizedBox(width: 8),
        ],
        AppBadge(
          label: '${(transaction.confidenceScore * 100).toInt()}%',
          size: AppBadgeSize.small,
          color: badgeColor,
        ),
      ],
    );
  }

  Widget _buildCardContent(ThemeData theme, NumberFormat currencyFormat) {
    final body = transaction.rawMessage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectionChanged(value ?? false),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountRow(theme, currencyFormat),
              const SizedBox(height: 4),
              Text(
                body.length > 50 ? '${body.substring(0, 50)}...' : body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              _buildBadgesRow(theme),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = CurrencyFormatter.getFormatter();
    final colors = theme.colorScheme;

    return AppCard(
      onTap: () => onSelectionChanged(!isSelected),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      backgroundColor: isSelected
          ? colors.primary.withAlpha(30)
          : colors.surface,
      borderColor: isSelected ? colors.primary : null,
      borderRadius: 16,
      child: _buildCardContent(theme, currencyFormat),
    );
  }
}
