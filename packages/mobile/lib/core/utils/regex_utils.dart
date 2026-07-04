// ignore_for_file: prefer-match-file-name

import 'dart:async';
import 'package:flutter/foundation.dart';

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

    return _matchWithTimeout(input, regex, timeout);
  }

  Iterable<Match> allMatches(String input) {
    final regex = _compiled;
    if (regex == null) return [];

    return _matchAllWithTimeout(input, regex, timeout);
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
      try {
        if (RegExp(dangerous).hasMatch(pattern)) {
          return true;
        }
      } catch (e, s) {
        debugPrint('Error: $e\n$s');
        debugPrint('RegexUtils: Failed to test dangerous pattern: $e');
      }
    }

    if (pattern.contains('({')) {
      final nestedQuantifiers = RegExp(r'\(\?|\(\*|\(\+');
      if (nestedQuantifiers.hasMatch(pattern)) {
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
    } catch (e, s) {
      debugPrint('Error: $e\n$s');

      return 'Invalid regex pattern: $e';
    }
  }

  void _compile() {
    try {
      _compiled = RegExp(pattern);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('TimedRegex: Failed to compile pattern: $e');
    }
  }

  static Match? _matchWithTimeout(
    String input,
    RegExp regex,
    Duration timeout,
  ) {
    Match? result;
    bool isTimedOut = false;

    final timer = Timer(timeout, () {
      isTimedOut = true;
    });

    try {
      for (final match in regex.allMatches(input)) {
        if (isTimedOut) break;
        result = match;
        break;
      }
    } finally {
      timer.cancel();
    }

    return result;
  }

  static Iterable<Match> _matchAllWithTimeout(
    String input,
    RegExp regex,
    Duration timeout,
  ) {
    final matches = <Match>[];
    bool isTimedOut = false;

    final timer = Timer(timeout, () {
      isTimedOut = true;
    });

    try {
      for (final match in regex.allMatches(input)) {
        if (isTimedOut) break;
        matches.add(match);
      }
    } finally {
      timer.cancel();
    }

    return matches;
  }
}
