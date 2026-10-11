import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('counts pick the right plural form in English', () {
    final found = t.notifications.scan.found;

    expect(found(n: 1), '1 new expense found');
    expect(found(n: 0), '0 new expenses found');
    expect(found(n: 5), '5 new expenses found');
  });

  test('counts read naturally in Bangla', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    expect(t.notifications.scan.found(n: 1), '1টি নতুন খরচ পাওয়া গেছে');
    expect(t.notifications.scan.found(n: 5), '5টি নতুন খরচ পাওয়া গেছে');
  });

  test('every supported language has a Bangla and an English build', () {
    expect(
      AppLocaleUtils.supportedLocalesRaw,
      containsAll(<String>['en', 'bn']),
    );
  });
}
