import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

class ShimmerBox extends StatelessWidget {
  final Widget child;

  const ShimmerBox({super.key, required this.child});

  static Widget circle({Key? key, required double size}) {
    return Container(
      key: key,
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget rectangle({
    Key? key,
    required double width,
    required double height,
    double borderRadius = 8.0,
  }) {
    return Container(
      key: key,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static Widget textLine({
    Key? key,
    double width = double.infinity,
    double height = 14.0,
  }) {
    return Container(
      key: key,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF3A4A52)
        : const Color(0xFFD4DDD0);
    final highlightColor = isDark
        ? AppColors.surfaceDark
        : AppColors.backgroundLight;

    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1200),
        child: child,
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const ShimmerList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
