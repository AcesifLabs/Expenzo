import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Record> transactions;
  const RecentTransactionsList({super.key, required this.transactions});

  static final Map<ExpenseSource, IconData> _sourceIcons = {
    ExpenseSource.manual: PiconsRegular.pencilSimple,
    ExpenseSource.sms: PiconsRegular.chatDots,
    ExpenseSource.email: PiconsRegular.envelope,
    ExpenseSource.recurring: PiconsRegular.arrowsClockwise,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currencyFormat = CurrencyFormatter.getFormatter(decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (transactions.isEmpty) {
      return const Center(child: Text('No recent transactions'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final record = transactions[index];
        final sourceIcon =
            _sourceIcons[record.source] ?? PiconsRegular.pencilSimple;
        final sourceColor = record.recordType == RecordType.expense
            ? colors.error
            : colors.secondary;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: sourceColor.withAlpha(20),
            child: Icon(sourceIcon, color: sourceColor, size: 20),
          ),
          title: Text(record.description),
          subtitle: Text(dateFormat.format(record.date)),
          trailing: Text(
            currencyFormat.format(record.amount),
            style: TextStyle(color: sourceColor, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
