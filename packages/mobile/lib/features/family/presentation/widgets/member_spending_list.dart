import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/group_summary.dart';
import '../../domain/entities/my_group.dart';
import '../helpers/family_dashboard_helpers.dart';
import 'member_avatar.dart';

class MemberSpendingList extends StatelessWidget {
  final MyGroup group;
  final GroupSummary summary;

  const MemberSpendingList({
    super.key,
    required this.group,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final memberIndex = {
      for (final (index, m) in group.members.indexed) m.userId: index,
    };
    final photos = {for (final m in group.members) m.userId: m.photoUrl};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.settings.family.sections.spendingByMember,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final member in summary.members)
          _MemberSpendingRow(
            member: member,
            ratio: spendingBarRatio(member, summary.members),
            label: memberLabel(
              userId: member.userId,
              displayName: member.displayName,
              myUserId: group.myUserId,
            ),
            index: memberIndex[member.userId] ?? 0,
            photoUrl: photos[member.userId],
            amount: CurrencyFormatter.formatIn(
              member.spent,
              summary.currencyCode,
            ),
          ),
      ],
    );
  }
}

class _MemberSpendingRow extends StatelessWidget {
  final MemberSpending member;
  final double ratio;
  final String label;
  final int index;
  final String? photoUrl;
  final String amount;

  const _MemberSpendingRow({
    required this.member,
    required this.ratio,
    required this.label,
    required this.index,
    required this.photoUrl,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          MemberAvatar(
            displayName: member.displayName,
            photoUrl: photoUrl,
            index: index,
            radius: 16,
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(amount, style: textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: palette.progressTrack,
                    color: palette.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
