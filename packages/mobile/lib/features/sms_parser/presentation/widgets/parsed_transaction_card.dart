import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/money_format.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_badge.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

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

  Widget _buildAmountRow(ThemeData theme, MoneyFormat currencyFormat) {
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
        const SizedBox(width: AppSpacing.sm),
        AppBadge(
          label: t.enums.source.sms,
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
            label: t.smsParser.card.rule(id: transaction.matchedRuleId ?? ''),
            size: AppBadgeSize.small,
            color: colors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        AppBadge(
          label: '${(transaction.confidenceScore * 100).toInt()}%',
          size: AppBadgeSize.small,
          color: badgeColor,
        ),
      ],
    );
  }

  Widget _buildCardContent(ThemeData theme, MoneyFormat currencyFormat) {
    final body = transaction.rawMessage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectionChanged(value ?? false),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountRow(theme, currencyFormat),
              const SizedBox(height: AppSpacing.xs),
              Text(
                body.length > 50 ? '${body.substring(0, 50)}...' : body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
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
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.smd),
      backgroundColor: isSelected
          ? colors.primary.withAlpha(30)
          : colors.surface,
      borderColor: isSelected ? colors.primary : null,
      borderRadius: AppSpacing.radiusControl,
      child: _buildCardContent(theme, currencyFormat),
    );
  }
}
