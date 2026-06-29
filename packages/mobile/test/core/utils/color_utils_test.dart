import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';

void main() {
  group('ColorUtils.fromHex', () {
    test('parses 6-digit hex without hash', () {
      final color = ColorUtils.fromHex('FF0000');
      expect(color, const Color(0xFFFF0000));
    });

    test('parses 6-digit hex with hash', () {
      final color = ColorUtils.fromHex('#00FF00');
      expect(color, const Color(0xFF00FF00));
    });

    test('uses fallback for invalid hex', () {
      final color = ColorUtils.fromHex(
        'invalid',
        fallback: const Color(0xFF5A7863),
      );
      expect(color, const Color(0xFF5A7863));
    });

    test('parses dark color correctly', () {
      final color = ColorUtils.fromHex('#1C1C1E');
      expect(color, const Color(0xFF1C1C1E));
    });
  });

  group('ColorUtils.fromHexWithAlpha', () {
    test('returns color with 38 alpha (15% opacity)', () {
      final color = ColorUtils.fromHexWithAlpha('#FF0000');
      expect(color.alpha, 38);
      expect(color.red, 255);
      expect(color.green, 0);
      expect(color.blue, 0);
    });
  });
}
