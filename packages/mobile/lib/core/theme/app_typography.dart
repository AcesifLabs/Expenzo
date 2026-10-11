import 'package:flutter/material.dart';

/// Lato, six sizes, two weights (docs/adr/0005).
///
/// | Size | Slots | Use |
/// |---|---|---|
/// | 32 | display*, headlineLarge | key figures |
/// | 24 | headlineMedium, headlineSmall | page titles |
/// | 18 | titleLarge | section titles |
/// | 16 | titleMedium, bodyLarge | body |
/// | 14 | titleSmall, bodyMedium, labelLarge | secondary text, buttons |
/// | 12 | bodySmall, labelMedium, labelSmall | captions, nav labels |
///
/// Widgets read these through `Theme.of(context).textTheme`.
abstract final class AppTypography {
  static const fontFamily = 'Lato';

  /// Lato has no Bangla glyphs; Bangla text falls back to Noto Sans Bengali.
  static const fontFamilyFallback = ['NotoSansBengali'];

  /// Digits of equal width so amounts line up in lists and columns.
  static const tabularFigures = [FontFeature.tabularFigures()];

  static const _regular = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w400,
  );
  static const _bold = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle displayLarge = _bold.copyWith(
    fontSize: 32,
    height: 1.2,
  );
  static final TextStyle displayMedium = displayLarge;
  static final TextStyle displaySmall = displayLarge;
  static final TextStyle headlineLarge = displayLarge;
  static final TextStyle headlineMedium = _bold.copyWith(
    fontSize: 24,
    height: 1.25,
  );
  static final TextStyle headlineSmall = headlineMedium;
  static final TextStyle titleLarge = _bold.copyWith(fontSize: 18, height: 1.3);
  static final TextStyle titleMedium = _bold.copyWith(
    fontSize: 16,
    height: 1.4,
  );
  static final TextStyle titleSmall = _bold.copyWith(fontSize: 14, height: 1.4);
  static final TextStyle bodyLarge = _regular.copyWith(
    fontSize: 16,
    height: 1.5,
  );
  static final TextStyle bodyMedium = _regular.copyWith(
    fontSize: 14,
    height: 1.45,
  );
  static final TextStyle bodySmall = _regular.copyWith(
    fontSize: 12,
    height: 1.4,
  );
  static final TextStyle labelLarge = _bold.copyWith(fontSize: 14);
  static final TextStyle labelMedium = _bold.copyWith(fontSize: 12);
  static final TextStyle labelSmall = _regular.copyWith(
    fontSize: 12,
    letterSpacing: 0.2,
  );

  /// Money amounts: bold with tabular figures.
  static final TextStyle currency = _bold.copyWith(
    fontSize: 18,
    fontFeatures: tabularFigures,
  );
}
