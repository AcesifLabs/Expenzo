import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class AppSkeletonTile extends StatelessWidget {
  final double circleSize;
  final double line1Width;
  final double? line2Width;

  const AppSkeletonTile({
    super.key,
    this.circleSize = 40,
    this.line1Width = 150,
    this.line2Width,
  });

  @override
  Widget build(BuildContext context) {
    final localLine2Width = line2Width;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: ShimmerBox.circle(size: circleSize),
        title: ShimmerBox.textLine(width: line1Width),
        subtitle: localLine2Width != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ShimmerBox.textLine(width: localLine2Width),
              )
            : null,
      ),
    );
  }
}
