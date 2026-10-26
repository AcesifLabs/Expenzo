import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/regex_utils.dart';
import '../entities/parsing_rule.dart';
import '../entities/parsed_transaction.dart';
import '../entities/evaluate_rules_params.dart';
import '../entities/parsing_context.dart';
import 'amount_match_resolver.dart' as amount_match_resolver;
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';
import '../entities/date_order.dart';
import 'rule_date.dart';

class RuleEvaluator {
  static ParsedTransaction? evaluateWithContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    final templateResult = _evaluateTemplates(context, params);
    if (templateResult != null) return templateResult;

    return _evaluateRules(context, params);
  }

  @visibleForTesting
  static Match? resolveAmountMatch(
    List<Match> allMatches,
    String? selectedAmount,
    String rawMessage,
  ) => amount_match_resolver.resolveAmountMatch(
    allMatches,
    selectedAmount,
    rawMessage,
  );

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
      final allMatches = matchAllWithBudget(regex, params.rawMessage);
      final selectedAmount = template.selectedAmount;

      final amountMatch = resolveAmountMatch(
        allMatches,
        selectedAmount,
        params.rawMessage,
      );

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

  static double? _extractAmount(Match amountMatch) {
    final amountStr = amountMatch.group(1) ?? amountMatch.group(0);
    if (amountStr == null) return null;

    return amount_match_resolver.parseResolvedAmount(amountStr);
  }

  static ParsedTransaction? _evaluateRule(
    ParsingRule rule,
    EvaluateRulesParams params,
    Map<String, RegExp> regexCache,
  ) {
    try {
      final regex =
          regexCache[rule.amountPattern] ?? RegExp(rule.amountPattern);
      final amountMatch = matchFirstWithBudget(regex, params.rawMessage);

      if (amountMatch == null) return null;

      final amount = _extractAmount(amountMatch);

      if (amount == null) return null;
      final datePattern = rule.datePattern;
      final date = datePattern != null
          ? _extractDate(datePattern, rule.dateOrder, params, regexCache)
          : null;

      final snippetStart = _calcSnippetStart(amountMatch.start);
      final snippetEnd = _calcSnippetEnd(
        amountMatch.end,
        params.rawMessage.length,
      );
      final description = params.rawMessage
          .substring(snippetStart, snippetEnd)
          .trim();

      final confidenceScore = _computeConfidenceScore(date);

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
    DateOrder dateOrder,
    EvaluateRulesParams params,
    Map<String, RegExp> regexCache,
  ) {
    final dateRegex = regexCache[datePattern] ?? RegExp(datePattern);
    final dateMatch = matchFirstWithBudget(dateRegex, params.rawMessage);
    if (dateMatch == null) return null;

    return parseRuleDate(dateMatch.group(0) ?? '', dateOrder);
  }

  static int _calcSnippetStart(int matchStart) {
    return matchStart > 20 ? matchStart - 20 : 0;
  }

  static int _calcSnippetEnd(int matchEnd, int messageLength) {
    return matchEnd + 20 < messageLength ? matchEnd + 20 : messageLength;
  }

  static double _computeConfidenceScore(DateTime? date) =>
      date != null ? 1.0 : 0.9;
}
