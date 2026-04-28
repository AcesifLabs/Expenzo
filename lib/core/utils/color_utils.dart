import 'package:flutter/material.dart';

/// Single source of truth for hex → Color parsing.
class ColorUtils {
  ColorUtils._();

  /// Parses a hex string (with or without `#`) to [Color].
  /// Falls back to [fallback] on failure.
  static Color fromHex(String hex, {Color fallback = const Color(0xFF5A7863)}) {
    try {
      final sanitized = hex.replaceFirst('#', '');
      return Color(int.parse('0xFF$sanitized'));
    } catch (_) {
      return fallback;
    }
  }

  /// Same as [fromHex] but with 15% opacity alpha applied.
  static Color fromHexWithAlpha(
    String hex, {
    Color fallback = const Color(0xFF5A7863),
  }) {
    return fromHex(hex, fallback: fallback).withAlpha(38); // ~15%
  }
}
