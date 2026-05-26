import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/date_amount.dart';
import '../../domain/repositories/reports_repository.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<DateAmount> data;
  final Granularity granularity;

  const SpendingTrendChart({
    super.key,
    required this.data,
    required this.granularity,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();

    final maxY = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colors.onSurface.withAlpha(20),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _getInterval(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _formatDate(data[index].date),
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurface.withAlpha(140),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAmount(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurface.withAlpha(140),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: colors.primary,
                    strokeWidth: 2,
                    strokeColor: colors.surface,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withAlpha(50),
                  colors.primary.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => colors.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < data.length) {
                  return LineTooltipItem(
                    '৳${data[index].amount.toStringAsFixed(0)}',
                    TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '\n${_formatDate(data[index].date)}',
                        style: TextStyle(
                          color: colors.onSurface.withAlpha(140),
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getInterval() {
    if (data.length <= 7) return 1;
    if (data.length <= 30) return 5;
    return 10;
  }

  String _formatDate(DateTime date) {
    switch (granularity) {
      case Granularity.daily:
        return DateFormat('dd/MM').format(date);
      case Granularity.weekly:
        return DateFormat('dd/MM').format(date);
      case Granularity.monthly:
        return DateFormat('MMM').format(date);
    }
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      return '৳${(value / 1000).toStringAsFixed(1)}k';
    }
    return '৳${value.toStringAsFixed(0)}';
  }
}
