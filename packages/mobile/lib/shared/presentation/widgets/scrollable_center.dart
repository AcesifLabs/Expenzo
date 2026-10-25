import 'dart:math';

import 'package:flutter/material.dart';

/// Centres [child] when it fits and scrolls it when it doesn't, as on a
/// small phone at the largest text size.
class ScrollableCenter extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const ScrollableCenter({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Padding(
            padding: padding,
            child: Center(child: child),
          );
        }

        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: max(0, constraints.maxHeight - padding.vertical),
            ),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
