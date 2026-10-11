import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_icon_tile.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_section.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_tile.dart';
import '../../../../support/pump_localized.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      pumpLocalized(tester, Scaffold(body: ListView(children: [child])));

  Finder checkIcon() => find.byIcon(PiconsRegular.checkCircle);

  FontWeight? titleWeight(WidgetTester tester, String title) =>
      tester.widget<Text>(find.text(title)).style?.fontWeight;

  testWidgets('an empty section renders nothing', (tester) async {
    await pump(tester, const SettingsSection(title: 'General', children: []));

    expect(find.text('GENERAL'), findsNothing);
  });

  testWidgets('a section shows its upper-cased title, rows and dividers', (
    tester,
  ) async {
    await pump(
      tester,
      const SettingsSection(
        title: 'General',
        children: [Text('Row one'), Text('Row two')],
      ),
    );

    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('Row one'), findsOneWidget);
    expect(find.text('Row two'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('a section without a title shows its rows and no header', (
    tester,
  ) async {
    await pump(
      tester,
      const SettingsSection(title: null, children: [Text('Sign out')]),
    );

    expect(find.text('Sign out'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.header == true,
      ),
      findsNothing,
    );
  });

  testWidgets('the icon tile colours its child: brand when selected, '
      'tertiary when disabled', (tester) async {
    await pump(
      tester,
      const Row(
        children: [
          SettingsIconTile(
            selected: true,
            child: Icon(Icons.circle, key: Key('on')),
          ),
          SettingsIconTile(
            enabled: false,
            child: Icon(Icons.circle, key: Key('off')),
          ),
        ],
      ),
    );

    Color? colorOf(String key) =>
        IconTheme.of(tester.element(find.byKey(Key(key)))).color;
    expect(colorOf('on'), AppPalette.dark.onBrandFill);
    expect(colorOf('off'), AppPalette.dark.textTertiary);
  });

  testWidgets('a settings tile shows its subtitle and calls onTap', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      SettingsTile(
        icon: PiconsRegular.sun,
        title: 'Appearance',
        subtitle: 'Dark',
        onTap: () => taps++,
      ),
    );

    expect(find.text('Dark'), findsOneWidget);
    await tester.tap(find.text('Appearance'));
    expect(taps, 1);
  });

  testWidgets('a choice tile shows the check mark only when selected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      Column(
        children: [
          SettingsChoiceTile(title: 'Light', selected: false, onTap: () {}),
          SettingsChoiceTile(title: 'Dark', selected: true, onTap: () {}),
        ],
      ),
    );

    expect(checkIcon(), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Dark'),
        matching: checkIcon(),
      ),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(find.text('Dark')),
      isSemantics(
        isSelected: true,
        isEnabled: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('a choice tile with an icon shows the icon tile and a bold '
      'title only when selected', (tester) async {
    await pump(
      tester,
      Column(
        children: [
          SettingsChoiceTile(
            title: 'Light',
            icon: PiconsRegular.sun,
            selected: false,
            onTap: () {},
          ),
          SettingsChoiceTile(
            title: 'Dark',
            icon: PiconsRegular.moon,
            selected: true,
            onTap: () {},
          ),
        ],
      ),
    );

    expect(find.byIcon(PiconsRegular.sun), findsOneWidget);
    expect(find.byIcon(PiconsRegular.moon), findsOneWidget);
    expect(titleWeight(tester, 'Dark'), FontWeight.w700);
    expect(titleWeight(tester, 'Light'), isNot(FontWeight.w700));
  });

  testWidgets('a disabled choice tile ignores taps', (tester) async {
    var taps = 0;
    await pump(
      tester,
      SettingsChoiceTile(
        title: 'JPY',
        selected: false,
        enabled: false,
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.text('JPY'));
    expect(taps, 0);
  });

  testWidgets('a section header upper-cases its title and is a header', (
    tester,
  ) async {
    await pump(tester, const SettingsSectionHeader(title: 'General'));

    expect(find.text('GENERAL'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('GENERAL')),
      matchesSemantics(label: 'GENERAL', isHeader: true),
    );
  });

  testWidgets('section slots divide rows and round only the outer corners', (
    tester,
  ) async {
    await pump(
      tester,
      const Column(
        children: [
          SettingsSectionSlot(isFirst: true, isLast: false, child: Text('a')),
          SettingsSectionSlot(isFirst: false, isLast: false, child: Text('b')),
          SettingsSectionSlot(isFirst: false, isLast: true, child: Text('c')),
        ],
      ),
    );

    BorderRadius radiusOf(String text) {
      final box = tester.widget<Container>(
        find
            .ancestor(of: find.text(text), matching: find.byType(Container))
            .first,
      );

      return (box.decoration! as BoxDecoration).borderRadius! as BorderRadius;
    }

    expect(find.byType(Divider), findsNWidgets(2));
    expect(radiusOf('a').topLeft, isNot(Radius.zero));
    expect(radiusOf('a').bottomLeft, Radius.zero);
    expect(radiusOf('b'), BorderRadius.zero);
    expect(radiusOf('c').topLeft, Radius.zero);
    expect(radiusOf('c').bottomLeft, isNot(Radius.zero));
  });
}
