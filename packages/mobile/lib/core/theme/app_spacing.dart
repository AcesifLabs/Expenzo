import 'package:flutter/material.dart';

/// Spacing, corner radii and motion tokens (docs/adr/0005).
///
/// Spacing follows a 4px grid: 4, 8, 12, 16, 24, 32, 48.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double smd = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Left and right margin of every page.
  static const double pageGutter = lg;
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageGutter,
  );

  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  /// Cards, bottom sheets and dialogs.
  static const double radiusCard = 24;

  /// Buttons, text fields, list tiles and snackbars.
  static const double radiusControl = 16;

  /// Chips, badges and progress bars.
  static const double radiusPill = 999;

  /// Minimum size of anything tappable (Material accessibility guideline).
  static const double minTapTarget = 48;

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
}
