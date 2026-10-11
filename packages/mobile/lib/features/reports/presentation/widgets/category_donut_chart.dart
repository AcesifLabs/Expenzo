import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import '../../domain/entities/category_amount.dart';
import '../helpers/category_chart_color.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class CategoryDonutChart extends StatelessWidget {
  final List<CategoryAmount> data;

  const CategoryDonutChart({super.key, required this.data});

  List<PieChartSectionData> _buildSections(AppPalette palette) {
    return data.map((item) {
      final color = categoryChartColor(item, palette);

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
      return SizedBox(
        width: 160,
        height: 160,
        child: Center(
          child: Text(
            t.reports.noCategoryData,
            style: AppTypography.bodySmall.copyWith(
              color: context.palette.textSecondary,
            ),
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
          sections: _buildSections(context.palette),
        ),
      ),
    );
  }
}
