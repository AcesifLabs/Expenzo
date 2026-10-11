import 'package:flutter/material.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'read_only_record_tile.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class BudgetTransactionList extends StatelessWidget {
  final List<Record> records;

  /// Defaults to "No transactions in this period" in the app language.
  final String? emptyMessage;

  const BudgetTransactionList({
    super.key,
    required this.records,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Text(
            emptyMessage ?? t.common.noTransactionsInPeriod,
            style: AppTypography.bodyMedium.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return ReadOnlyRecordTile(record: records[index]);
      },
    );
  }
}
