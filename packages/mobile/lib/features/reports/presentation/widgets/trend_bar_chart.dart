import 'package:flutter/material.dart';
import '../../domain/entities/date_amount.dart';

class TrendBarChart extends StatelessWidget {
  static const _defaultColor = Color(0x308E8E93);
  static const _primaryColor = Color(0xFFD1C4E9);
  static const _peakColor = Color(0xFFF48FB1);

  final List<DateAmount> data;

  const TrendBarChart({super.key, required this.data});

  List<double> _normalizedBars() {
    if (data.isEmpty) return const [];

    final amounts = data.map((item) => item.amount.abs()).toList();
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) {
      return List<double>.filled(amounts.length, 0.2);
    }

    return amounts
        .map((amount) => (amount / maxAmount).clamp(0.14, 1.0))
        .toList();
  }

  Color _barColor(int index, int length, double height) {
    if (height >= 0.92) return _peakColor;
    if (index == length - 1 || index % 5 == 0) return _primaryColor;

    return _defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final bars = _normalizedBars();

    if (bars.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No trend data yet',
            style: TextStyle(fontSize: 12, color: Color(0x80F5F7FA)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < bars.length; i++) ...[
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 200 * bars[i],
                    decoration: BoxDecoration(
                      color: _barColor(i, bars.length, bars[i]),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              if (i != bars.length - 1) const SizedBox(width: 3),
            ],
          ],
        ),
      ),
    );
  }
}
