import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

Future<void> _pumpFab(WidgetTester tester, Widget fab) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(floatingActionButton: fab),
  ),
);

void main() {
  testWidgets('an extended FAB is as wide as its label, not a circle', (
    tester,
  ) async {
    await _pumpFab(
      tester,
      FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(PiconsRegular.robot),
        label: const Text('Scan past SMS'),
      ),
    );

    final fab = tester.getSize(find.byType(FloatingActionButton));
    final label = tester.getSize(find.text('Scan past SMS'));
    expect(fab.width, greaterThan(fab.height));
    expect(fab.width, greaterThan(label.width));
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byType(Material),
      ),
    );
    expect(material.shape, isA<StadiumBorder>());
  });

  testWidgets('a regular FAB is still a circle', (tester) async {
    await _pumpFab(
      tester,
      FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );

    final fab = tester.getSize(find.byType(FloatingActionButton));
    expect(fab.width, fab.height);
  });

  testWidgets('switching light and dark mode animates the FAB label safely', (
    tester,
  ) async {
    Widget app(ThemeMode mode) => MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      home: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('Ask AI'),
        ),
      ),
    );

    await tester.pumpWidget(app(ThemeMode.light));
    await tester.pumpWidget(app(ThemeMode.dark));
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(ThemeMode.light));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final label = tester.widget<RichText>(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byType(RichText),
      ),
    );
    expect(label.text.style?.fontFamily, 'Lato');
    expect(label.text.style?.fontWeight, FontWeight.w700);
  });
}
