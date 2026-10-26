import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double smd = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double pageGutter = lg;
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageGutter,
  );

  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  static const double radiusCard = 24;

  static const double radiusControl = 16;

  static const double radiusPill = 999;

  static const double minTapTarget = 48;

  static const double fieldHeight = 52;

  static const double iconTile = 40;

  static const double iconSm = 16;

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
}
