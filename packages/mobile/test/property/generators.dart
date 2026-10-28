import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:kiri_check/kiri_check.dart';

const propertyTrials = int.fromEnvironment(
  'PROPERTY_TRIALS',
  defaultValue: 200,
);

Arbitrary<int> positiveCents() =>
    integer(min: 1, max: (AppConstants.maxAmount * 100).round());

Arbitrary<int> everydayCents() => integer(min: 1, max: 1000000000);

Arbitrary<DateTime> anyDateTime() =>
    combine2(
      integer(min: 0, max: 36524),
      integer(min: 0, max: 24 * 60 * 60 - 1),
    ).map((v) {
      final (day, second) = v;

      return DateTime(2000, 1, 1 + day, 0, 0, second);
    });

Arbitrary<String> smsNoise({int maxLength = 80}) => string(
  maxLength: maxLength,
  characterSet: CharacterSet.fromCharacters(
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789০১২৩৪৫৬৭৮৯ .,:;/-*#@()৳\$₹টাকাপরিশোধ\n',
  ),
);

Arbitrary<String> anyText({int maxLength = 60}) =>
    string(
      maxLength: maxLength,
      characterSet: CharacterSet.all(CharacterEncoding.utf8),
    ).map(
      (s) =>
          String.fromCharCodes(s.runes.where((r) => r < 0xD800 || r > 0xDFFF)),
    );

String centsText(int cents, {bool decimals = true}) {
  final whole = cents ~/ 100;
  final fraction = (cents % 100).toString().padLeft(2, '0');

  return decimals ? '$whole.$fraction' : '$whole';
}

String grouped(String digits, {required bool indian}) {
  if (digits.length <= 3) return digits;
  final head = digits.substring(0, digits.length - 3);
  final tail = digits.substring(digits.length - 3);
  final size = indian ? 2 : 3;
  final groups = <String>[];
  for (var end = head.length; end > 0; end -= size) {
    groups.insert(0, head.substring(end - size < 0 ? 0 : end - size, end));
  }

  return '${groups.join(',')},$tail';
}

String banglaDigits(String text) => String.fromCharCodes(
  text.runes.map((r) => r >= 0x30 && r <= 0x39 ? 0x09E6 + r - 0x30 : r),
);
