import 'dart:convert';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/utils/strict_date.dart';
import 'package:expense_tracker/core/utils/money.dart';

import '../domain/entities/receipt_extraction.dart';

class ReceiptExtractionParser {
  const ReceiptExtractionParser();

  ReceiptExtraction parse(String raw) {
    final cleaned = _stripThinking(raw).trim();
    final decoded = _decodeJsonObject(cleaned);
    final amount = _parseAmount(decoded['amount']);
    final description = _parseDescription(decoded['description']);
    final date = _parseDate(decoded['date']);
    final categoryName = _parseOptionalString(decoded['category']);

    if (description.isEmpty) {
      throw FormatException('Receipt description is empty');
    }

    return ReceiptExtraction(
      amount: amount,
      description: description,
      date: date,
      categoryName: categoryName,
    );
  }

  String _stripThinking(String raw) {
    return raw
        .replaceAll(
          RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'<thinking>[\s\S]*?</thinking>', caseSensitive: false),
          '',
        );
  }

  Map<String, Object?> _decodeJsonObject(String text) {
    for (final candidate in _jsonObjectCandidates(text)) {
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map) {
          return Map<String, Object?>.from(decoded);
        }
      } on FormatException {
        continue;
      }
    }

    throw FormatException(
      'Receipt extraction response is not JSON (${text.length} chars)',
    );
  }

  Iterable<String> _jsonObjectCandidates(String text) sync* {
    final outer = <(int, int)>[];
    final nested = <(int, int)>[];
    final openBraces = <int>[];
    var inString = false;
    var escaped = false;

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (inString) {
        final next = _advanceStringState(ch, escaped);
        inString = next.inString;
        escaped = next.escaped;
      } else if (ch == '"') {
        inString = openBraces.isNotEmpty;
      } else if (ch == '{') {
        openBraces.add(i);
      } else if (ch == '}' && openBraces.isNotEmpty) {
        final start = openBraces.removeLast();
        (openBraces.isEmpty ? outer : nested).add((start, i + 1));
      }
    }
    nested.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (start, end) in [...outer.reversed, ...nested]) {
      yield text.substring(start, end);
    }
  }

  ({bool inString, bool escaped}) _advanceStringState(String ch, bool escaped) {
    if (escaped) return (inString: true, escaped: false);
    if (ch == r'\') return (inString: true, escaped: true);
    if (ch == '"') return (inString: false, escaped: false);

    return (inString: true, escaped: false);
  }

  double _parseAmount(Object? value) {
    final amount = switch (value) {
      null => throw const ReceiptTotalUnreadableException(),
      num() => value.toDouble(),
      String() =>
        _amountFromText(value) ??
            (throw const ReceiptTotalUnreadableException()),
      _ => null,
    };
    if (amount == null || !amount.isFinite) {
      throw const FormatException('Invalid receipt amount');
    }

    final rounded = roundMoney(amount);
    if (rounded == 0) throw const ReceiptTotalUnreadableException();
    if (rounded < 0 || rounded > AppConstants.maxAmount) {
      throw const FormatException('Receipt amount is out of range');
    }

    return rounded;
  }

  double? _amountFromText(String text) {
    var digits = text.replaceAll(RegExp(r'[^0-9.,\-]'), '');
    final lastDot = digits.lastIndexOf('.');
    final lastComma = digits.lastIndexOf(',');
    final decimalComma =
        lastComma > lastDot &&
        (lastDot >= 0 || RegExp(r'^-?\d+,\d{2}$').hasMatch(digits));
    digits = decimalComma
        ? digits.replaceAll('.', '').replaceAll(',', '.')
        : digits.replaceAll(',', '');

    return double.tryParse(digits);
  }

  String _parseDescription(Object? value) {
    if (value is String) return value.trim();
    if (value == null) return '';

    return value.toString().trim();
  }

  String? _parseOptionalString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    return text;
  }

  DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    final match = RegExp(
      r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})',
    ).firstMatch(value.toString().trim());
    if (match == null) return null;
    final [year, month, day] = [
      for (final group in match.groups([1, 2, 3])) int.parse(group ?? ''),
    ];

    return strictDate(year, month, day);
  }
}
