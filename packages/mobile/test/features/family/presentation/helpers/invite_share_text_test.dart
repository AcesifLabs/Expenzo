import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:expense_tracker/features/family/presentation/helpers/invite_share_text.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  final invite = InviteCode(
    code: 'RF4XK2',
    expiresAt: DateTime.utc(2026, 3, 3, 10),
  );

  setUpAll(() async {
    await initializeDateFormatting();
    DateFormat.useNativeDigitsByDefaultFor('bn', false);
  });

  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('the share text names the group, the code and the expiry', () {
    final text = buildInviteShareText(
      groupName: 'Rahman Family',
      invite: invite,
      locale: 'en',
    );

    expect(text, contains('Rahman Family'));
    expect(text, contains('RF4XK2'));
    expect(text, contains(formatInviteExpiry(invite.expiresAt, 'en')));
  });

  test('in Bangla the text is Bangla and digits stay Latin', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    final text = buildInviteShareText(
      groupName: 'রহমান পরিবার',
      invite: invite,
      locale: 'bn',
    );

    expect(text, contains('পারিবারিক গ্রুপ'));
    expect(text, isNot(matches(RegExp('[০-৯]'))));
  });

  test('the expiry is shown in local time', () {
    final local = invite.expiresAt.toLocal();

    expect(
      formatInviteExpiry(invite.expiresAt, 'en'),
      DateFormat.MMMd('en').add_jm().format(local),
    );
  });
}
