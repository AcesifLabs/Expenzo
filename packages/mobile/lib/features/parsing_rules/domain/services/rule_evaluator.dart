import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/regex_utils.dart';
import '../entities/parsed_transaction.dart';
import '../entities/evaluate_rules_params.dart';
import '../entities/parsing_context.dart';
import 'amount_match_resolver.dart' as amount_match_resolver;
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';

class RuleEvaluator {
  static ParsedTransaction? evaluateWithContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    return _evaluateTemplates(context, params);
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
}
