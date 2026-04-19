import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/expense_source.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Expense> transactions;
  final String currencySymbol;
  final VoidCallback? onViewAll;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.currencySymbol = '৳',
    this.onViewAll,
  });

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
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildTransactionTile(context, transactions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Expense expense) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getSourceColor(expense.source).withValues(alpha: 0.2),
        child: Icon(
          _getSourceIcon(expense.source),
          size: 20,
          color: _getSourceColor(expense.source),
        ),
      ),
      title: Text(
        expense.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        dateFormat.format(expense.date),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        currencyFormat.format(expense.amount.abs()),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: expense.amount < 0 ? Colors.red : null,
        ),
      ),
    );
  }

  IconData _getSourceIcon(ExpenseSource source) {
    switch (source) {
      case ExpenseSource.manual:
        return Icons.edit;
      case ExpenseSource.sms:
        return Icons.sms;
      case ExpenseSource.email:
        return Icons.email;
      case ExpenseSource.recurring:
        return Icons.repeat;
    }
  }

  Color _getSourceColor(ExpenseSource source) {
    switch (source) {
      case ExpenseSource.manual:
        return Colors.blue;
      case ExpenseSource.sms:
        return Colors.green;
      case ExpenseSource.email:
        return Colors.orange;
      case ExpenseSource.recurring:
        return Colors.purple;
    }
  }
}
