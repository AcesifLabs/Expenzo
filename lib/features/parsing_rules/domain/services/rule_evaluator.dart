import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/utils/regex_utils.dart';
import '../entities/parsing_rule.dart';
import '../entities/parsed_transaction.dart';
import '../entities/parsing_types.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';

/// Pure-Dart evaluation functions — works in isolates and main thread.
class RuleEvaluator {
  static String normalizeAmount(String amount) =>
      amount.replaceAll(RegExp(r'[^\d.]'), '');

  static ParsedTransaction? evaluateWithContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    // 1. Check all user-defined templates across all monitored sources
    for (final source in context.sources) {
      if (!source.isMonitored) continue;
      if (source.contactId != params.address) continue;

      final contactTemplates = context.templates
          .where((t) => t.sourceId == source.id)
          .toList();

      for (final template in contactTemplates) {
        if (params.rawMessage.toLowerCase().contains(
          template.triggerWord.toLowerCase(),
        )) {
          final candidate = _evaluateTemplate(
            template,
            params,
            source,
            context.regexCache,
          );
          if (candidate != null) {
            return candidate;
          }
        }
      }
    }

    // 2. Fall back to global parsing rules (already sorted by priority)
    for (final rule in context.rules) {
      if (rule.sourceType == SourceType.sms &&
          params.sourceType != AppSourceType.sms) {
        continue;
      }
      if (rule.sourceType == SourceType.email &&
          params.sourceType != AppSourceType.email) {
        continue;
      }
      if (rule.sourceType == SourceType.email &&
          params.sourceType != SourceType.email) {
        continue;
      }

      if (!rule.matchesTriggerWord(params.rawMessage)) {
        continue;
      }

      final candidate = _evaluateRule(rule, params, context.regexCache);
      if (candidate != null) {
        return candidate;
      }
    }

    return null;
  }

  static ParsedTransaction? _evaluateTemplate(
    ExpenseTemplate template,
    EvaluateRulesParams params,
    MessageSource monitoredSource,
    Map<String, RegExp> regexCache,
  ) {
    try {
      final regex =
          regexCache[template.amountPattern] ?? RegExp(template.amountPattern);
      final allMatches = regex.allMatches(params.rawMessage).toList();

      Match? amountMatch;

      if (template.selectedAmount != null && allMatches.isNotEmpty) {
        final targetNormalized = normalizeAmount(template.selectedAmount!);
        Match? exactMatch;
        for (final m in allMatches) {
          final numericPortion = m.group(2) ?? m.group(0) ?? '';
          if (normalizeAmount(numericPortion) == targetNormalized) {
            exactMatch = m;
            break;
          }
        }
        amountMatch = exactMatch ?? allMatches.first;
      } else if (allMatches.isNotEmpty) {
        amountMatch = allMatches.first;
      }

      if (amountMatch == null) return null;

      double? amount;
      final amountStr = amountMatch.group(2) ?? amountMatch.group(0);
      if (amountStr != null) {
        final cleanAmount = normalizeAmount(amountStr);
        amount = double.tryParse(cleanAmount);
      }

      if (amount == null) return null;

      String description = template.descriptionPattern ?? 'Template Expense';
      if (params.messageDate != null) {
        final formattedDate = DateFormat(
          'dd MMM yyyy \'at\' HH:mm',
        ).format(params.messageDate!);
        description = '${monitoredSource.contactName} - $formattedDate';
      }

      return ParsedTransaction(
        rawMessage: params.rawMessage,
        amount: amount,
        date: params.messageDate,
        description: description,
        categoryId: template.categoryId,
        sourceType: params.sourceType,
        sourceId: params.sourceId,
        confidenceScore: 0.95,
        matchedRuleId: template.id,
        parseFailed: false,
        parseError: null,
      );
    } catch (e) {
      return null;
    }
  }

  static ParsedTransaction? _evaluateRule(
    ParsingRule rule,
    EvaluateRulesParams params,
    Map<String, RegExp> regexCache,
  ) {
    try {
      final regex =
          regexCache[rule.amountPattern] ?? RegExp(rule.amountPattern);
      final amountMatch = regex.firstMatch(params.rawMessage);

      if (amountMatch == null) return null;

      double? amount;
      String? description;
      DateTime? date;

      final amountStr = amountMatch.group(1) ?? amountMatch.group(0);
      if (amountStr != null) {
        final cleanAmount = normalizeAmount(amountStr);
        amount = double.tryParse(cleanAmount);
      }

      if (rule.datePattern != null) {
        final dateRegex =
            regexCache[rule.datePattern!] ?? RegExp(rule.datePattern!);
        final dateMatch = dateRegex.firstMatch(params.rawMessage);
        if (dateMatch != null) {
          date = _parseDate(dateMatch.group(0) ?? '');
        }
      }

      final snippetStart = amountMatch.start > 20 ? amountMatch.start - 20 : 0;
      final snippetEnd = amountMatch.end + 20 < params.rawMessage.length
          ? amountMatch.end + 20
          : params.rawMessage.length;
      description = params.rawMessage
          .substring(snippetStart, snippetEnd)
          .trim();

      double confidenceScore = 0.7;
      if (amount != null && date != null) {
        confidenceScore = 1.0;
      } else if (amount != null) {
        confidenceScore = 0.9;
      }

      return ParsedTransaction(
        rawMessage: params.rawMessage,
        amount: amount,
        date: date,
        description: description,
        categoryId: rule.categoryId,
        sourceType: params.sourceType,
        sourceId: params.sourceId,
        confidenceScore: confidenceScore,
        matchedRuleId: rule.id,
        parseFailed: false,
        parseError: null,
      );
    } catch (e) {
      return ParsedTransaction(
        rawMessage: params.rawMessage,
        amount: null,
        date: null,
        description: null,
        categoryId: null,
        sourceType: params.sourceType,
        sourceId: params.sourceId,
        confidenceScore: 0.0,
        matchedRuleId: rule.id,
        parseFailed: true,
        parseError: e.toString(),
      );
    }
  }

  static DateTime? _parseDate(String dateStr) {
    final datePatterns = [
      RegExp(r'(\d{2})/(\d{2})/(\d{4})'),
      RegExp(r'(\d{2})-(\d{2})-(\d{4})'),
      RegExp(r'(\d{4})/(\d{2})/(\d{2})'),
      RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(dateStr);
      if (match == null) continue;

      final g1 = match.group(1);
      final g2 = match.group(2);
      final g3 = match.group(3);
      if (g1 == null || g2 == null || g3 == null) continue;

      final int? n1 = int.tryParse(g1);
      final int? n2 = int.tryParse(g2);
      final int? n3 = int.tryParse(g3);
      if (n1 == null || n2 == null || n3 == null) continue;

      if (n1 > 31) {
        return _safeDateTime(n1, n2, n3); // year, month, day
      } else {
        return _safeDateTime(n3, n1, n2); // month, day, year → year, month, day
      }
    }
    return null;
  }

  static DateTime? _safeDateTime(int year, int month, int day) {
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}
