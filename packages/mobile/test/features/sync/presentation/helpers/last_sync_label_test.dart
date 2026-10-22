import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/sync/presentation/helpers/last_sync_label.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    DateFormat.useNativeDigitsByDefaultFor('bn', false);
  });

  setUp(() {
    Intl.defaultLocale = 'en';
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  tearDown(() {
    Intl.defaultLocale = null;
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  // intl puts a narrow no-break space (U+202F) before AM/PM.
  final now = DateTime(2026, 10, 15, 18);

  test('the same day reads Today', () {
    expect(
      lastSyncLabel(DateTime(2026, 10, 15, 3, 45), now),
      'Today, 3:45\u202fAM',
    );
  });

  test('the previous day reads Yesterday, also across a month', () {
    expect(
      lastSyncLabel(DateTime(2026, 10, 14, 21, 10), now),
      'Yesterday, 9:10\u202fPM',
    );
    expect(
      lastSyncLabel(DateTime(2026, 9, 30, 8), DateTime(2026, 10, 1, 9)),
      'Yesterday, 8:00\u202fAM',
    );
  });

  test('older dates show the full date and time', () {
    expect(
      lastSyncLabel(DateTime(2026, 10, 1, 8, 5), now),
      'Oct 1, 2026 8:05\u202fAM',
    );
  });

  test('Bangla uses Latin digits', () {
    Intl.defaultLocale = 'bn';
    LocaleSettings.setLocaleSync(AppLocale.bn);

    final label = lastSyncLabel(DateTime(2026, 10, 15, 3, 45), now);

    expect(label, startsWith('আজ, '));
    expect(label, contains('3:45'));
    expect(RegExp('[০-৯]').hasMatch(label), isFalse);
  });
}
