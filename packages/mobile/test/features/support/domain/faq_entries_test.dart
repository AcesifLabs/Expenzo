import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/support/domain/faq_entry.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

void main() {
  setUp(() => LocaleSettings.setLocaleSync(AppLocale.en));
  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('eight entries with unique ids and text', () {
    final entries = faqEntries();

    expect(entries, hasLength(8));
    expect(entries.map((e) => e.id).toSet(), hasLength(8));
    for (final entry in entries) {
      expect(entry.question, isNotEmpty);
      expect(entry.answer, isNotEmpty);
    }
  });

  test('a blank or whitespace query returns every entry', () {
    final entries = faqEntries();

    expect(filterFaqEntries(entries, ''), entries);
    expect(filterFaqEntries(entries, '   '), entries);
  });

  test('matching ignores case', () {
    final found = filterFaqEntries(faqEntries(), 'BUDGET');

    expect(found.map((e) => e.id), contains('budget'));
  });

  test('a word only in an answer finds that entry', () {
    final found = filterFaqEntries(faqEntries(), 'csv');

    expect(found.map((e) => e.id), ['export']);
  });

  test('an unknown word finds nothing', () {
    expect(filterFaqEntries(faqEntries(), 'zzzz'), isEmpty);
  });

  test('no entry says "backup" or "record", in either language', () {
    for (final locale in AppLocale.values) {
      LocaleSettings.setLocaleSync(locale);
      for (final entry in faqEntries()) {
        final text = '${entry.question} ${entry.answer}'.toLowerCase();
        expect(text, isNot(contains('backup')), reason: entry.id);
        expect(text, isNot(contains('record')), reason: entry.id);
        expect(text, isNot(contains('ব্যাকআপ')), reason: entry.id);
      }
    }
  });

  test('in Bangla the questions are the Bangla text', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    expect(faqEntries().first.question, 'কীভাবে লেনদেন যোগ করব?');
  });
}
