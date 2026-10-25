import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/money.dart';

/// The digits and decimal point of an SMS amount: Bangla digits become
/// Latin, everything else but digits and dots goes, and dots at either end
/// are dropped. That last step also removes the dot of a currency word:
/// `Tk.1,500.00` becomes `.1500.00`, then `1500.00`; `BDT 500.` becomes
/// `500`.
String normalizeResolvedAmount(String amount) => latinDigits(
  amount,
).replaceAll(RegExp(r'[^\d.]'), '').replaceAll(RegExp(r'^\.+|\.+$'), '');

/// The amount in matched SMS text, rounded to 2 decimals, or null when it
/// is not a usable amount: unreadable, zero, or above
/// [AppConstants.maxAmount]. A null amount skips the message; it never
/// becomes a 0 record.
double? parseResolvedAmount(String text) {
  final value = double.tryParse(normalizeResolvedAmount(text));
  if (value == null) return null;
  // Checked after rounding: 0.004 would otherwise become a 0.00 record.
  final rounded = roundMoney(value);

  // Never negative: normalizing drops the sign.
  return rounded == 0 || rounded > AppConstants.maxAmount ? null : rounded;
}

Match? resolveAmountMatch(
  List<Match> allMatches,
  String? selectedAmount,
  String rawMessage,
) {
  if (allMatches.isEmpty) return null;

  if (selectedAmount != null) {
    final exact = _findExactMatch(
      allMatches,
      normalizeResolvedAmount(selectedAmount),
    );
    if (exact != null) return exact;
  }

  Match? bestMatch;
  int bestScore = -1 << 30;

  for (final match in allMatches) {
    final score = _scoreAmountCandidate(match, rawMessage);
    if (score > bestScore) {
      bestScore = score;
      bestMatch = match;
    }
  }

  return bestMatch;
}

final _maskSuffixRegex = RegExp(r'(\*+|[xX]+)$');
final _balanceKeywordRegex = RegExp(
  r'(avl|bal|balance)\b',
  caseSensitive: false,
);
final _amountKeywordRegex = RegExp(
  r'(bdt|rs|inr|tk|৳|debited|spent|paid)\s*:?\s*$',
  caseSensitive: false,
);

int _scoreAmountCandidate(Match match, String rawMessage) {
  final matchText = match.group(0) ?? '';
  final beforeContext = rawMessage.substring(0, match.start);
  var score = 0;

  if (_maskSuffixRegex.hasMatch(beforeContext.trim())) score -= 50;
  if (_balanceKeywordRegex.hasMatch(beforeContext)) score -= 20;
  if (matchText.contains('.')) score += 3;
  if (_amountKeywordRegex.hasMatch(beforeContext)) score += 10;

  return score;
}

Match? _findExactMatch(List<Match> matches, String targetNormalized) {
  for (final m in matches) {
    final fullMatch = m.group(0) ?? '';
    final numericPortion = m.groupCount >= 1
        ? (m.group(1) ?? fullMatch)
        : fullMatch;
    if (normalizeResolvedAmount(numericPortion) == targetNormalized) {
      return m;
    }
  }

  return null;
}
