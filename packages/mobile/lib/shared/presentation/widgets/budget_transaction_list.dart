import 'package:flutter/material.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'read_only_record_tile.dart';

/// A scrollable list of read-only transaction tiles for budget drill-down.
class BudgetTransactionList extends StatelessWidget {
  final List<Record> records;
  final String emptyMessage;

  const BudgetTransactionList({
    super.key,
    required this.records,
    this.emptyMessage = 'No transactions in this period',
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        return ReadOnlyRecordTile(record: records[index]);
      },
    );
  }
}
