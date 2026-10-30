import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/budget_plan.dart';
import '../../domain/entities/plan_row.dart';
import '../helpers/plan_row_colors.dart';

class PlanDonut extends StatelessWidget {
  static const _size = 180.0;

  static PieChartSectionData _section(double value, Color color) =>
      PieChartSectionData(value: value, color: color, radius: 28, title: '');

  final List<PlanRow> rows;
  final double base;

  const PlanDonut({super.key, required this.rows, required this.base});

  @override
  Widget build(BuildContext context) {
    final planT = t.budgets.plan;
    final palette = context.palette;
    final colors = planRowColors(palette);
    final filled = planTotal(rows) > 0;
    final sections = [
      if (filled)
        for (final (index, row) in rows.indexed)
          if (row.amount > 0)
            _section(row.amount, colors[index % colors.length]),
      if (!filled) _section(1, palette.progressTrack),
    ];
    final entries = [
      for (final row in rows)
        '${row.name} ${CurrencyFormatter.format(row.amount)}',
    ].join(', ');

    return Semantics(
      label: planT.chartLabel(entries: entries),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: sections.length > 1 ? 2 : 0,
                  sections: sections,
                ),
              ),
              Text(
                planT.perMonth(
                  amount: CurrencyFormatter.format(base > 0 ? base : 0),
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
