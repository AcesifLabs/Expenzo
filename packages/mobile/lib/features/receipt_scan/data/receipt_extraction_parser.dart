import 'dart:convert';

import '../domain/entities/receipt_extraction.dart';

/// Parses the JSON payload returned by the multimodal receipt prompt.
class ReceiptExtractionParser {
  const ReceiptExtractionParser();

  ReceiptExtraction parse(String raw) {
    final cleaned = _stripThinking(raw).trim();
    final decoded = _decodeJsonObject(cleaned);
    final amount = _parseAmount(decoded['amount']);
    final description = _parseDescription(decoded['description']);
    final date = _parseDate(decoded['date']);
    final categoryName = _parseOptionalString(decoded['category']);

    if (amount <= 0) {
      throw FormatException('Receipt amount must be positive, got $amount');
    }
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
    // Prefer the last balanced {...} that decodes as a Map — models often
    // echo example JSON before the final answer.
    for (final candidate in _jsonObjectCandidates(text).toList().reversed) {
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map) {
          return Map<String, Object?>.from(decoded);
        }
      } catch (_) {
        // Try earlier candidate.
      }
    }

    throw FormatException('Receipt extraction response is not JSON: $text');
  }

  Iterable<String> _jsonObjectCandidates(String text) sync* {
    for (var i = 0; i < text.length; i++) {
      if (text[i] != '{') continue;
      final candidate = _balancedObjectFrom(text, i);
      if (candidate != null) yield candidate;
    }
  }

  /// Returns the balanced `{...}` starting at [start], or null if none closes.
  String? _balancedObjectFrom(String text, int start) {
    var depth = 0;
    var inString = false;
    var escaped = false;

    for (var j = start; j < text.length; j++) {
      final ch = text[j];
      if (inString) {
        final next = _advanceStringState(ch, escaped);
        inString = next.inString;
        escaped = next.escaped;
        continue;
      }
      if (ch == '"') {
        inString = true;
        continue;
      }
      if (ch == '{') depth++;
      if (ch == '}') {
        depth--;
        if (depth == 0) return text.substring(start, j + 1);
      }
    }

    return null;
  }

  ({bool inString, bool escaped}) _advanceStringState(String ch, bool escaped) {
    if (escaped) return (inString: true, escaped: false);
    if (ch == r'\') return (inString: true, escaped: true);
    if (ch == '"') return (inString: false, escaped: false);

    return (inString: true, escaped: false);
  }

  double _parseAmount(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.\-]'), '');
      final parsed = double.tryParse(cleaned);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid receipt amount: $value');
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
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    final iso = DateTime.tryParse(text);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    final match = RegExp(
      r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$',
    ).firstMatch(text);
    if (match != null) {
      final yearText = match.group(1);
      final monthText = match.group(2);
      final dayText = match.group(3);
      if (yearText == null || monthText == null || dayText == null) {
        return null;
      }
      final year = int.parse(yearText);
      final month = int.parse(monthText);
      final day = int.parse(dayText);
      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }
}
