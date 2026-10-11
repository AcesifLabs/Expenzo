import 'package:expense_tracker/features/sms_parser/presentation/helpers/scan_range_label_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  final may3 = DateTime(2026, 5, 3);
  final may9 = DateTime(2026, 5, 9);

  setUpAll(() async {
    await initializeDateFormatting();
    DateFormat.useNativeDigitsByDefaultFor('bn', false);
  });

  tearDown(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    Intl.defaultLocale = null;
  });

  group('in English', () {
    setUp(() => LocaleSettings.setLocaleSync(AppLocale.en));

    test('a single day shows one date', () {
      expect(formatScanRangeLabel(startDate: may3, endDate: may3), 'May 3');
    });

    test('a range shows both ends', () {
      expect(
        formatScanRangeLabel(startDate: may3, endDate: may9),
        'May 3 – May 9',
      );
    });

    test('open ranges say from or until', () {
      expect(
        formatScanRangeLabel(startDate: may3, endDate: null),
        'From May 3',
      );
      expect(
        formatScanRangeLabel(startDate: null, endDate: may9),
        'Until May 9',
      );
    });

    test('no dates means all time', () {
      expect(
        formatScanRangeLabel(startDate: null, endDate: null),
        t.smsParser.range.allTime,
      );
    });
  });

  test('in Bangla, month names are translated and digits stay Latin', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);
    Intl.defaultLocale = 'bn';

    final label = formatScanRangeLabel(startDate: may3, endDate: null);

    expect(label, contains('মে'));
    expect(label, contains('3'));
    expect(label, endsWith('থেকে'));
  });
}
