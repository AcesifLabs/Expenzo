import 'package:flutter/foundation.dart';

/// Default per-match budget for user-supplied regex patterns.
const Duration kRegexMatchBudget = Duration(milliseconds: 250);

class TimedRegex {
  final String pattern;
  final Duration timeout;
  RegExp? _compiled;

  TimedRegex({
    required this.pattern,
    this.timeout = const Duration(seconds: 2),
  }) {
    _compile();
  }

  Match? firstMatch(String input) {
    final regex = _compiled;
    if (regex == null) return null;

    return matchFirstWithBudget(regex, input, timeout);
  }

  Iterable<Match> allMatches(String input) {
    final regex = _compiled;
    if (regex == null) return [];

    return matchAllWithBudget(regex, input, timeout);
  }

  static bool isDangerousPattern(String pattern) {
    final dangerousPatterns = [
      r'(a+)+',
      r'(a*)+',
      r'(a{1000})+',
      r'(\w+)+',
      r'(\d+)+',
      r'(.*)+',
      r'(.+)+',
    ];

    for (final dangerous in dangerousPatterns) {
      if (pattern.contains(dangerous)) {
        return true;
      }
    }

    return false;
  }

  static String? validatePattern(String pattern) {
    try {
      RegExp(pattern);
      if (isDangerousPattern(pattern)) {
        return 'Warning: Pattern may cause catastrophic backtracking';
      }

      return null;
    } catch (e) {
      return 'Invalid regex pattern: $e';
    }
  }

  void _compile() {
    try {
      _compiled = RegExp(pattern);
    } catch (e) {
      debugPrint('TimedRegex: Failed to compile pattern: $e');
    }
  }
}

/// Runs [regex.firstMatch] on [input] and returns null if it exceeds [budget].
///
/// This is a post-hoc guard: the regex still runs to completion, but if it
/// takes longer than [budget] the result is discarded and a warning is logged.
/// For true interrupt-based protection, use a separate isolate.
Match? matchFirstWithBudget(
  RegExp regex,
  String input, [
  Duration budget = kRegexMatchBudget,
]) {
  final sw = Stopwatch()..start();
  final result = regex.firstMatch(input);
  sw.stop();

  if (sw.elapsed > budget) {
    debugPrint(
      'RegexUtils: firstMatch exceeded budget '
      '(${sw.elapsedMilliseconds}ms > ${budget.inMilliseconds}ms)',
    );

    return null;
  }

  return result;
}

/// Runs [regex.allMatches] on [input] and returns empty if it exceeds [budget].
///
/// Same post-hoc guard as [matchFirstWithBudget].
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
