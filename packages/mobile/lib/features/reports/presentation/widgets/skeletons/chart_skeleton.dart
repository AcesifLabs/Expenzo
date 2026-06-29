import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});

  Widget _buildChipRow() {
    final chip = ShimmerBox.rectangle(width: 80, height: 32, borderRadius: 16);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        chip,
        const SizedBox(width: 8),
        chip,
        const SizedBox(width: 8),
        chip,
      ],
    );
  }

  Widget _buildYAxis() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        5,
        (_) => ShimmerBox.textLine(width: 40, height: 10),
      ),
    );
  }

  Widget _buildChartArea() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildYAxis(),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerBox.rectangle(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXAxis() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (_) => ShimmerBox.textLine(width: 30, height: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChipRow(),
            const SizedBox(height: 16),
            _buildChartArea(),
            const SizedBox(height: 8),
            _buildXAxis(),
          ],
        ),
      ),
    );
  }
}
