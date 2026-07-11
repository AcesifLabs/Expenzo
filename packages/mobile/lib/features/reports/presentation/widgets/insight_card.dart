import 'package:flutter/material.dart';
import '../../domain/entities/insight_item.dart';

class InsightCard extends StatelessWidget {
  final InsightItem item;

  const InsightCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2B292C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF5F7FA),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
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
