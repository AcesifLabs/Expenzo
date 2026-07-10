String normalizeResolvedAmount(String amount) =>
    amount.replaceAll(RegExp(r'[^\d.]'), '');

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
