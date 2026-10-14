import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';

void main() {
  test('each size has its scale factor', () {
    expect(AppFontSize.small.scale, 0.9);
    expect(AppFontSize.medium.scale, 1.0);
    expect(AppFontSize.large.scale, 1.15);
    expect(AppFontSize.extraLarge.scale, 1.3);
  });

  test('the default is medium', () {
    expect(AppFontSize.defaultSize, AppFontSize.medium);
  });

  group('AppFontSize.fromName', () {
    test('returns the matching value', () {
      expect(AppFontSize.fromName('large'), AppFontSize.large);
      expect(AppFontSize.fromName('extraLarge'), AppFontSize.extraLarge);
    });

    test('returns null for an unknown name', () {
      expect(AppFontSize.fromName('huge'), isNull);
    });

    test('returns null for null', () {
      expect(AppFontSize.fromName(null), isNull);
    });
  });

  test('labels read the translated strings', () {
    expect(AppFontSize.small.displayName, 'Small');
    expect(AppFontSize.extraLarge.displayName, 'Extra large');
    expect(AppFontSize.medium.description, 'Balanced size for everyday use');
  });
}
