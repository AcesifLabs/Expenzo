import 'package:flutter/foundation.dart';

const Duration kRegexMatchBudget = Duration(milliseconds: 250);

List<Match> matchAllWithBudget(
  RegExp regex,
  String input, [
  Duration budget = kRegexMatchBudget,
]) {
  final sw = Stopwatch()..start();
  final result = regex.allMatches(input).toList();
  sw.stop();

  if (sw.elapsed > budget) {
    debugPrint(
      'RegexUtils: allMatches exceeded budget '
      '(${sw.elapsedMilliseconds}ms > ${budget.inMilliseconds}ms)',
    );

    return [];
  }

  return result;
}
