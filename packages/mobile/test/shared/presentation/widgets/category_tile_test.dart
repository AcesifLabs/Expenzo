import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';
import '../../../support/pump_localized.dart';

void main() {
  Future<Icon> pumpTile(WidgetTester tester, String hex) async {
    await tester.pumpWidget(
      translated(
        MaterialApp(
          home: CategoryTile(colorHex: hex, iconKey: 'trendUp'),
        ),
      ),
    );

    return tester.widget<Icon>(find.byType(Icon));
  }

  testWidgets('palette tiles get a dark icon', (tester) async {
    for (final option in CategoryPalette.all) {
      final icon = await pumpTile(tester, option.hex);
      expect(icon.color, const Color(0xFF1C1C1E), reason: option.name);
    }
  });

  testWidgets('saturated colors chosen before v17 get a white icon', (
    tester,
  ) async {
    expect((await pumpTile(tester, '#3949AB')).color, Colors.white);
  });

  test('every seeded icon key has its own icon, not the fallback', () {
    const fallback = PiconsRegular.package;
    for (final key in ['trendUp', 'tag', 'ticket', 'currencyDollar', 'bag']) {
      expect(AppIcons.getCategoryIcon(key), isNot(fallback), reason: key);
    }
  });
}
