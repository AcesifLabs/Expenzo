import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../records/domain/entities/record.dart';
import "package:expense_tracker/core/constants/source_types.dart";

class RecentTransactionsList extends StatelessWidget {
  final List<Record> transactions;
  final String currencySymbol;
  final VoidCallback? onViewAll;

  // Memoized formatters — created once, reused across all builds
  static final _dateFormat = DateFormat('MMM dd');
  static final _currencyFormats = <String, NumberFormat>{};

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.currencySymbol = '৳',
    this.onViewAll,
  });

  NumberFormat _currencyFormat() {
    return _currencyFormats.putIfAbsent(
      currencySymbol,
      () => NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2),
    );
  }

  // Static lookup tables — avoid switch allocation per build
  static const _sourceIcons = {
    ExpenseSource.manual: Icons.edit,
    ExpenseSource.sms: Icons.sms,
    ExpenseSource.email: Icons.email,
    ExpenseSource.recurring: Icons.repeat,
  };

  static const _sourceColors = {
    ExpenseSource.manual: Colors.blue,
    ExpenseSource.sms: Colors.green,
    ExpenseSource.email: Colors.orange,
    ExpenseSource.recurring: Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No transactions yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final currencyFmt = _currencyFormat();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _TransactionTile(
                record: transactions[index],
                currencyFormat: currencyFmt,
                dateFormat: _dateFormat,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Record record;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;

  const _TransactionTile({
    required this.record,
    required this.currencyFormat,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceColor =
        RecentTransactionsList._sourceColors[record.source] ?? Colors.blue;
    final sourceIcon =
        RecentTransactionsList._sourceIcons[record.source] ?? Icons.edit;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: sourceColor.withValues(alpha: 0.2),
        child: Icon(sourceIcon, size: 20, color: sourceColor),
      ),
      title: Text(
        record.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        dateFormat.format(record.date),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        currencyFormat.format(record.amount.abs()),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: record.amount < 0 ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
