import 'package:flutter/material.dart';

/// Centralized spacing and padding tokens for consistent layout.
abstract final class AppSpacing {
  // Base unit: 8px grid (half-unit: 4px)
  static const double unit = 4;
  static const double xs = 4; // 1 unit
  static const double sm = 8; // 2 units
  static const double md = 16; // 4 units
  static const double lg = 24; // 6 units
  static const double xl = 32; // 8 units
  static const double xxl = 48; // 12 units

  // Common EdgeInsets presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(
    horizontal: md,
  );

  // Border radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 999;

  // Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
}
