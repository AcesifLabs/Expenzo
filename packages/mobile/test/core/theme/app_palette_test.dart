import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

void main() {
  Future<AppPalette> paletteUnder(WidgetTester tester, ThemeData theme) async {
    late AppPalette palette;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            palette = context.palette;

            return const SizedBox.shrink();
          },
        ),
      ),
    );

    return palette;
  }

  testWidgets('light theme resolves the light palette', (tester) async {
    expect(await paletteUnder(tester, AppTheme.lightTheme), AppPalette.light);
  });

  testWidgets('dark theme resolves the dark palette', (tester) async {
    expect(await paletteUnder(tester, AppTheme.darkTheme), AppPalette.dark);
  });

  testWidgets('falls back to dark without an app theme', (tester) async {
    expect(await paletteUnder(tester, ThemeData()), AppPalette.dark);
  });

  test('lerp reaches each end and copyWith overrides one role', () {
    const light = AppPalette.light;
    const dark = AppPalette.dark;

    expect(light.lerp(dark, 0).bg, light.bg);
    expect(light.lerp(dark, 1).bg, dark.bg);
    expect(light.lerp(null, 0.5), same(light));

    final tweaked = light.copyWith(accent: const Color(0xFF000000));
    expect(tweaked.accent, const Color(0xFF000000));
    expect(tweaked.bg, light.bg);
  });

  group('brand (docs/adr/0003)', () {
    test('mint is primary in both modes; lavender is secondary', () {
      final light = AppTheme.lightTheme.colorScheme;
      final dark = AppTheme.darkTheme.colorScheme;

      expect(light.primary, AppPalette.light.brand);
      expect(light.primaryContainer, const Color(0xFFA2D3A4));
      expect(dark.primary, const Color(0xFFA2D3A4));
      expect(light.secondary, AppPalette.light.accent);
      expect(dark.secondary, AppPalette.dark.accent);
    });

    test('income and brand are different hues', () {
      for (final palette in [AppPalette.light, AppPalette.dark]) {
        expect(palette.income, isNot(palette.brand));
        expect(palette.income, isNot(palette.brandFill));
      }
    });

    test('filled buttons and the add button use the mint fill', () {
      final theme = AppTheme.lightTheme;

      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        AppPalette.light.brandFill,
      );
      expect(
        theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}),
        AppPalette.light.brandFill,
      );
    });
  });

  group('contrast', () {
    double ratio(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final hi = la > lb ? la : lb;
      final lo = la > lb ? lb : la;

      return (hi + 0.05) / (lo + 0.05);
    }

    for (final (mode, p) in [
      ('light', AppPalette.light),
      ('dark', AppPalette.dark),
    ]) {
      test('$mode: text roles reach 4.5:1 on every background', () {
        final text = {
          'textPrimary': p.textPrimary,
          'textSecondary': p.textSecondary,
          'brand': p.brand,
          'accent': p.accent,
          'income': p.income,
          'expense': p.expense,
          'info': p.info,
        };
        for (final MapEntry(key: name, value: fg) in text.entries) {
          for (final (bgName, bg) in [('bg', p.bg), ('surface', p.surface)]) {
            expect(
              ratio(fg, bg),
              greaterThanOrEqualTo(4.5),
              reason: '$mode $name on $bgName',
            );
          }
        }
        // Warning is used for icons and short labels on cards.
        expect(ratio(p.warning, p.surface), greaterThanOrEqualTo(4.5));
      });

      test('$mode: labels on brand and accent fills are readable', () {
        expect(ratio(p.onBrandFill, p.brandFill), greaterThanOrEqualTo(4.5));
        expect(ratio(p.onAccentFill, p.accentFill), greaterThanOrEqualTo(4.5));
      });
    }
  });
}
