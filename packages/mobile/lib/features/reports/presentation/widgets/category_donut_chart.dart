import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/category_amount.dart';

class CategoryDonutChart extends StatelessWidget {
  static const _colors = [
    Color(0xFFD1C4E9),
    Color(0xFFA2D3A4),
    Color(0xFF90CAF9),
    Color(0xFFF48FB1),
    Color(0x608E8E93),
  ];

  final List<CategoryAmount> data;

  const CategoryDonutChart({super.key, required this.data});

  List<PieChartSectionData> _buildSections() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final color = _colors[index % _colors.length];

      return PieChartSectionData(
        color: color,
        value: item.amount,
        radius: 32,
        title: '',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        width: 160,
        height: 160,
        child: Center(
          child: Text(
            'No category data',
            style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
          ),
        ),
      );
    }

    return SizedBox(
      width: 160,
      height: 160,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 48,
          sectionsSpace: 2,
          sections: _buildSections(),
        ),
      ),
    );
  }
}
