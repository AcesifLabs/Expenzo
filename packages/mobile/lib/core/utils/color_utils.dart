import 'dart:ui';

class ColorUtils {
  ColorUtils._();

  static Color fromHex(String hex, {Color fallback = const Color(0xFF5A7863)}) {
    try {
      final sanitized = hex.replaceFirst('#', '');

      return Color(int.parse('0xFF$sanitized'));
    } catch (e) {
      return fallback;
    }
  }

  static Color fromHexWithAlpha(
    String hex, {
    Color fallback = const Color(0xFF5A7863),
  }) {
    return fromHex(hex, fallback: fallback).withAlpha(38);
  }
}
