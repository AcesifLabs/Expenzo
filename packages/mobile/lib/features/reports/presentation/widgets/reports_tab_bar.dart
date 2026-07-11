import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class ReportsTabBar extends StatelessWidget {
  static const _tabs = ['Trend', 'Categories', 'Insights'];
  static const _activeWidths = {
    'Trend': 40.0,
    'Categories': 60.0,
    'Insights': 50.0,
  };

  final TabController controller;
  final ValueChanged<String> onTabChanged;

  const ReportsTabBar({
    super.key,
    required this.controller,
    required this.onTabChanged,
  });

  Color _labelColor(double selectedness) {
    return Color.lerp(
          const Color(0xFF8E8E93),
          const Color(0xFFD1C4E9),
          selectedness,
        ) ??
        const Color(0xFF8E8E93);
  }

  FontWeight _fontWeight(double selectedness) {
    return FontWeight.lerp(FontWeight.normal, FontWeight.w600, selectedness) ??
        FontWeight.normal;
  }

  double _animationValue() {
    return controller.animation?.value ?? controller.index.toDouble();
  }

  double _underlineWidth(double value) {
    final leftIndex = value.floor().clamp(0, _tabs.length - 1);
    final rightIndex = value.ceil().clamp(0, _tabs.length - 1);
    final t = value - leftIndex;
    final leftWidth = _activeWidths[_tabs[leftIndex]] ?? 40;
    final rightWidth = _activeWidths[_tabs[rightIndex]] ?? 40;

    return lerpDouble(leftWidth, rightWidth, t) ?? leftWidth;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: controller.animation ?? controller,
        builder: (context, _) {
          final value = _animationValue();

          return LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / _tabs.length;
              final underlineWidth = _underlineWidth(value);
              final underlineLeft =
                  ((value + 0.5) * tabWidth) - (underlineWidth / 2);

              return Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _tabs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tab = entry.value;
                      final selectedness = (1 - (value - index).abs()).clamp(
                        0.0,
                        1.0,
                      );

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTabChanged(tab),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tab,
                                style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 14,
                                  fontWeight: _fontWeight(selectedness),
                                  color: _labelColor(selectedness),
                                ),
                              ),
                              const SizedBox(height: 9),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Positioned(
                    left: underlineLeft,
                    bottom: 0,
                    child: Container(
                      width: underlineWidth,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1C4E9),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
