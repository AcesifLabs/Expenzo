import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/features/family/domain/entities/group_summary.dart';
import 'package:expense_tracker/features/family/presentation/helpers/family_dashboard_helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../../support/factories/family_factory.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  test('memberInitial takes the first grapheme, ? when empty', () {
    expect(memberInitial('karim'), 'K');
    expect(memberInitial('ক্ষমা'), 'ক্ষ');
    expect(memberInitial('  '), '?');
    expect(memberInitial(null), '?');
  });

  test('memberLabel marks me and falls back without a name', () {
    expect(
      memberLabel(userId: 'u1', displayName: 'Karim', myUserId: 'u1'),
      'Karim (you)',
    );
    expect(
      memberLabel(userId: 'u2', displayName: 'Rina', myUserId: 'u1'),
      'Rina',
    );
    expect(
      memberLabel(userId: 'u2', displayName: null, myUserId: 'u1'),
      'Family member',
    );
  });

  test(
    'spendingBarRatio is 1 for the biggest spender and 0 when nobody spent',
    () {
      const top = MemberSpending(userId: 'a', spent: 80);
      const half = MemberSpending(userId: 'b', spent: 40);
      const none = MemberSpending(userId: 'c', spent: 0);

      expect(spendingBarRatio(top, const [top, half]), 1);
      expect(spendingBarRatio(half, const [top, half]), 0.5);
      expect(spendingBarRatio(none, const [none]), 0);
    },
  );

  test('lastUpdatedLabel shows a time today and a date otherwise', () {
    final now = DateTime(2026, 4, 15, 18);
    final today = DateTime(2026, 4, 15, 9, 30);
    final earlier = DateTime(2026, 4, 12, 9, 30);

    expect(
      lastUpdatedLabel(today, now, 'en'),
      DateFormat.jm('en').format(today),
    );
    expect(
      lastUpdatedLabel(earlier, now, 'en'),
      DateFormat.MMMd('en').add_jm().format(earlier),
    );
  });

  test(
    'memberAvatarColor never uses income or expense colours and cycles after 6',
    () {
      final colors = [for (var i = 0; i < 12; i++) memberAvatarColor(i)];
      final teal = ColorUtils.fromHex(CategoryPalette.teal.hex);
      final rose = ColorUtils.fromHex(CategoryPalette.rose.hex);

      expect(colors, isNot(contains(teal)));
      expect(colors, isNot(contains(rose)));
      expect(colors.first, ColorUtils.fromHex(CategoryPalette.mint.hex));
      expect(colors[6], colors[0]);
    },
  );

  test('avatarSlice shows 5 and counts the rest', () {
    List<String> ids(int n) => [for (var i = 0; i < n; i++) 'u$i'];
    final three = avatarSlice([
      for (final id in ids(3)) makeGroupMember(userId: id),
    ]);
    final seven = avatarSlice([
      for (final id in ids(7)) makeGroupMember(userId: id),
    ]);

    expect((three.shown.length, three.more), (3, 0));
    expect((seven.shown.length, seven.more), (5, 2));
  });
}
