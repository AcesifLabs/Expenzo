import 'package:flutter/material.dart';

class MetricBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const MetricBox({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 11,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}
