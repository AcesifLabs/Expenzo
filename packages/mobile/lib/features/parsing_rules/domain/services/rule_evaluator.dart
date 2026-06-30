import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../entities/parsing_rule.dart';
import '../entities/parsed_transaction.dart';
import '../entities/evaluate_rules_params.dart';
import '../entities/parsing_context.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';

class RuleEvaluator {
  static String normalizeAmount(String amount) =>
      amount.replaceAll(RegExp(r'[^\d.]'), '');

  static ParsedTransaction? evaluateWithContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    final templateResult = _evaluateTemplates(context, params);
    if (templateResult != null) return templateResult;

    return _evaluateRules(context, params);
  }

  static ParsedTransaction? _evaluateTemplates(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
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
          if (candidate != null) return candidate;
        }
      }
    }

    return null;
  }

  static ParsedTransaction? _evaluateRules(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    for (final rule in context.rules) {
      final sourceTypeMatch = switch (rule.sourceType) {
        SourceType.sms => params.sourceType == AppSourceType.sms,
        SourceType.email => params.sourceType == AppSourceType.email,
        SourceType.both => true,
      };
      if (!sourceTypeMatch) continue;

      if (!rule.matchesTriggerWord(params.rawMessage)) continue;

      final candidate = _evaluateRule(rule, params, context.regexCache);
      if (candidate != null) return candidate;
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
      final selectedAmount = template.selectedAmount;

      final amountMatch = _resolveAmountMatch(allMatches, selectedAmount);

      if (amountMatch == null) return null;

      final amount = _extractAmount(amountMatch);
      if (amount == null) return null;

      final messageDate = params.messageDate;
      final description = messageDate != null
          ? '${monitoredSource.contactName} - ${DateFormat('dd MMM yyyy \'at\' HH:mm').format(messageDate)}'
          : template.descriptionPattern ?? 'Template Expense';

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
    } catch (e, s) {
      appLogger.error('Error evaluating context', e, s);
      return null;
    }
  }

  static Match? _resolveAmountMatch(
    List<Match> allMatches,
    String? selectedAmount,
  ) {
    if (selectedAmount != null && allMatches.isNotEmpty) {
      return _findExactMatch(allMatches, normalizeAmount(selectedAmount));
    }
    if (allMatches.isNotEmpty) {
      return allMatches.first;
    }

    return null;
  }

  static Match? _findExactMatch(List<Match> matches, String targetNormalized) {
    for (final m in matches) {
      final numericPortion = m.group(2) ?? m.group(0) ?? '';
      if (normalizeAmount(numericPortion) == targetNormalized) {
        return m;
      }
    }

    return matches.first;
  }

  static double? _extractAmount(Match amountMatch) {
    final amountStr = amountMatch.group(2) ?? amountMatch.group(0);
    if (amountStr == null) return null;

    final cleanAmount = normalizeAmount(amountStr);

    return double.tryParse(cleanAmount);
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

      final amount = _extractAmount(amountMatch);
      final datePattern = rule.datePattern;
      final date = datePattern != null
          ? _extractDate(datePattern, params, regexCache)
          : null;

      final snippetStart = _calcSnippetStart(amountMatch.start);
      final snippetEnd = _calcSnippetEnd(
        amountMatch.end,
        params.rawMessage.length,
      );
      final description = params.rawMessage
          .substring(snippetStart, snippetEnd)
          .trim();

      final confidenceScore = _computeConfidenceScore(amount, date);

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
    } catch (e, s) {
      appLogger.error('Error evaluating with context', e, s);
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

  static DateTime? _extractDate(
    String datePattern,
    EvaluateRulesParams params,
    Map<String, RegExp> regexCache,
  ) {
    final dateRegex = regexCache[datePattern] ?? RegExp(datePattern);
    final dateMatch = dateRegex.firstMatch(params.rawMessage);
    if (dateMatch == null) return null;

    return _parseDate(dateMatch.group(0) ?? '');
  }

  static int _calcSnippetStart(int matchStart) {
    return matchStart > 20 ? matchStart - 20 : 0;
  }

  static int _calcSnippetEnd(int matchEnd, int messageLength) {
    return matchEnd + 20 < messageLength ? matchEnd + 20 : messageLength;
  }

  static double _computeConfidenceScore(double? amount, DateTime? date) {
    if (amount != null && date != null) return 1.0;
    if (amount != null) return 0.9;

    return 0.7;
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

      final n1 = int.tryParse(g1);
      final n2 = int.tryParse(g2);
      final n3 = int.tryParse(g3);
      if (n1 == null || n2 == null || n3 == null) continue;

      return n1 > 31 ? _safeDateTime(n1, n2, n3) : _safeDateTime(n3, n1, n2);
    }

    return null;
  }

  static DateTime? _safeDateTime(int year, int month, int day) {
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    try {
      return DateTime(year, month, day);
    } catch (e) {
      appLogger.error('Rule evaluation error', e);
      return null;
    }
  }
}
