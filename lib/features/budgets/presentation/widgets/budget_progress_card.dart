import 'package:flutter/material.dart';
import '../../domain/entities/budget.dart';

class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAmount =
        budget.amount + (budget.rolloverEnabled ? budget.rolloverAmount : 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.categoryId ?? 'Overall Budget',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '৳${budget.amount.toStringAsFixed(2)} / ${budget.period.name}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (budget.rolloverEnabled && budget.rolloverAmount > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Includes ৳${budget.rolloverAmount.toStringAsFixed(2)} rollover',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ],
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value:
                  0.5, // Placeholder - actual calculation would need expenses data
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 4),
            Text(
              'Effective budget: ৳${effectiveAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
