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

  FlLine _getHorizontalGridLine(double _, Color baseColor) {
    return FlLine(color: baseColor.withAlpha(20), strokeWidth: 1);
  }

  Widget _getBottomTitle(double value, Color baseColor) {
    final index = value.toInt();
    if (index >= 0 && index < data.length) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          _formatDate(data[index].date),
          style: TextStyle(fontSize: 10, color: baseColor.withAlpha(140)),
        ),
      );
    }

    return const Text('');
  }

  Widget _getLeftTitle(double value, Color baseColor) {
    return Text(
      _formatAmount(value),
      style: TextStyle(fontSize: 10, color: baseColor.withAlpha(140)),
    );
  }

  List<LineTooltipItem?> _getTooltips(
    List<LineBarSpot> touchedSpots,
    Color baseColor,
  ) {
    final items = <LineTooltipItem?>[];
    for (final spot in touchedSpots) {
      final index = spot.x.toInt();
      if (index >= 0 && index < data.length) {
        items.add(
          LineTooltipItem(
            '৳${data[index].amount.toStringAsFixed(0)}',
            TextStyle(color: baseColor, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: '\n${_formatDate(data[index].date)}',
                style: TextStyle(
                  color: baseColor.withAlpha(140),
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      } else {
        items.add(null);
      }
    }

    return items;
  }

  FlGridData _buildGridData(double maxY, ColorScheme colors) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxY > 0 ? maxY / 4 : 1,
      getDrawingHorizontalLine: (value) =>
          _getHorizontalGridLine(value, colors.onSurface),
    );
  }

  FlTitlesData _buildTitles(ColorScheme colors) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: _getInterval(),
          getTitlesWidget: (value, meta) =>
              _getBottomTitle(value, colors.onSurface),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: (value, meta) =>
              _getLeftTitle(value, colors.onSurface),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineChartBarData _buildLineBars(List<FlSpot> spots, ColorScheme colors) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: colors.primary,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
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
          colors: [colors.primary.withAlpha(50), colors.primary.withAlpha(0)],
        ),
      ),
    );
  }

  LineTouchData _buildTouchData(ColorScheme colors) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (spot) => colors.surface,
        getTooltipItems: (touchedSpots) =>
            _getTooltips(touchedSpots, colors.onSurface),
      ),
    );
  }

  LineChartData _buildChartData(ColorScheme colors) {
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();
    final maxY = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return LineChartData(
      gridData: _buildGridData(maxY, colors),
      titlesData: _buildTitles(colors),
      borderData: FlBorderData(show: false),
      lineBarsData: [_buildLineBars(spots, colors)],
      lineTouchData: _buildTouchData(colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LineChart(_buildChartData(colors));
  }
}
