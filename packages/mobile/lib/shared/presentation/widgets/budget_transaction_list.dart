import 'package:flutter/material.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'read_only_record_tile.dart';

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
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 14,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return ReadOnlyRecordTile(record: records[index]);
      },
    );
  }
}
