import 'package:expense_tracker/core/utils/category_display_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => LocaleSettings.setLocaleSync(AppLocale.bn));
  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('an untouched default category is translated', () {
    expect(
      categoryDisplayName(id: 'default_out_food', name: 'Food & Dining'),
      'খাবার ও রেস্তোরাঁ',
    );
  });

  test('a renamed default category shows the name as typed', () {
    expect(
      categoryDisplayName(id: 'default_out_food', name: 'Groceries'),
      'Groceries',
    );
  });

  test('a custom category is never translated', () {
    expect(categoryDisplayName(id: 'abc-123', name: 'Salary'), 'Salary');
  });

  test('records without a category get a translated label', () {
    expect(
      categoryDisplayName(id: null, name: uncategorizedName),
      t.categories.uncategorized,
    );
  });

  test('every seeded category has a translation', () {
    for (final id in t.categories.defaults.keys) {
      expect(id, startsWith('default_'));
    }
    expect(t.categories.defaults, hasLength(18));
  });
}
