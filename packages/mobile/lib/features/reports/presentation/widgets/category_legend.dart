import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import '../../domain/entities/category_amount.dart';

class CategoryLegend extends StatelessWidget {
  static const _colors = [
    Color(0xFFD1C4E9),
    Color(0xFFA2D3A4),
    Color(0xFF90CAF9),
    Color(0xFFF48FB1),
    Color(0x608E8E93),
  ];

  final List<CategoryAmount> data;

  const CategoryLegend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = _colors[index % _colors.length];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.categoryName,
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      color: Color(0xFFF5F7FA),
                    ),
                  ),
                ),
                Text(
                  fmt.format(item.amount),
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF5F7FA),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
