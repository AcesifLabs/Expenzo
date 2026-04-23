import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../entities/parsed_transaction.dart';
import '../entities/parsing_rule.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';
import '../usecases/evaluate_rules.dart';

/// Service to offload heavy message parsing to a background isolate.
///
/// Usage:
/// ```dart
/// final service = ParsingIsolateService();
/// final results = await service.parseMessages(
///   messages: messages,
///   context: parsingContext,
///   sourceType: 'sms',
/// );
/// ```
class ParsingIsolateService {
  /// Parses all messages in a background isolate.
  ///
  /// Returns a list of [ParsedTransaction] for messages that matched rules.
  /// All DB data must be pre-loaded into [context] before calling this.
  Future<List<ParsedTransaction>> parseMessages({
    required List<ParseMessageInput> messages,
    required ParsingContext context,
    required String sourceType,
  }) async {
    if (messages.isEmpty) return [];

    final payload = _IsolatePayload(
      messages: messages,
      rules: context.rules,
      templates: context.templates,
      sources: context.sources,
      sourceType: sourceType,
    );

    // Use Isolate.run for one-shot background computation
    return Isolate.run(() => _parseInIsolate(payload));
  }
}

/// Input data for a single message to parse in the isolate.
class ParseMessageInput {
  final String body;
  final String address;
  final DateTime date;
  final String sourceId;

  const ParseMessageInput({
    required this.body,
    required this.address,
    required this.date,
    required this.sourceId,
  });
}

/// Payload sent to the background isolate. Contains all data needed
/// for parsing (no DB access required).
class _IsolatePayload {
  final List<ParseMessageInput> messages;
  final List<ParsingRule> rules;
  final List<ExpenseTemplate> templates;
  final List<MessageSource> sources;
  final String sourceType;

  const _IsolatePayload({
    required this.messages,
    required this.rules,
    required this.templates,
    required this.sources,
    required this.sourceType,
  });
}

/// Top-level function executed in the background isolate.
/// Reconstructs the ParsingContext and evaluates each message.
List<ParsedTransaction> _parseInIsolate(_IsolatePayload payload) {
  final context = ParsingContext(
    rules: payload.rules,
    templates: payload.templates,
    sources: payload.sources,
  );

  final evaluator = _IsolateEvaluator();
  final results = <ParsedTransaction>[];
  final processedIds = <String>{};

  for (final message in payload.messages) {
    // Skip duplicates within the batch
    if (processedIds.contains(message.sourceId)) continue;
    processedIds.add(message.sourceId);

    debugPrint('Isolate: Evaluating message from ${message.address}: "${message.body}"');

    final parsed = evaluator.evaluateWithPreloadedContext(
      context,
      EvaluateRulesParams(
        rawMessage: message.body,
        sourceType: payload.sourceType,
        sourceId: message.sourceId,
        address: message.address,
        messageDate: message.date,
      ),
    );

    if (parsed != null && !parsed.parseFailed && parsed.amount != null) {
      debugPrint('Isolate: Message matched! Amount: ${parsed.amount}, Category: ${parsed.categoryId}');
      results.add(parsed);
    } else {
      debugPrint('Isolate: Message did not match any rule/template.');
    }
  }

  // Sort by confidence (highest first)
  results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

  return results;
}

/// Lightweight evaluator for use in background isolates.
/// Duplicates the evaluation logic from EvaluateRulesUseCase but
/// avoids any dependency on Flutter or DB classes.
class _IsolateEvaluator {
  static String _normalizeAmountForComparison(String amount) {
    return amount.replaceAll(RegExp(r'[^\d.]'), '');
  }

  ParsedTransaction? evaluateWithPreloadedContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    // Check user-defined templates first
    final monitoredSource = context.sources.cast<dynamic>().firstWhere(
      (s) => s.contactId == params.address && s.isMonitored,
      orElse: () => null,
    );

    if (monitoredSource != null) {
      final contactTemplates = context.templates
          .where((t) => t.sourceId == monitoredSource.id)
          .toList();

      for (final template in contactTemplates) {
        if (params.rawMessage.toLowerCase().contains(
          template.triggerWord.toLowerCase(),
        )) {
          final candidate = _evaluateTemplateSync(
            template,
            params,
            monitoredSource,
          );
          if (candidate != null) {
            return candidate;
          }
        }
      }

      if (contactTemplates.isNotEmpty) {
        return null;
      }
    }

    // Fall back to global parsing rules (already sorted by priority)
    for (final rule in context.rules) {
      if (rule.sourceType == SourceType.sms && params.sourceType != 'sms') {
        continue;
      }
      if (rule.sourceType == SourceType.email && params.sourceType != 'email') {
        continue;
      }

      if (!rule.matchesTriggerWord(params.rawMessage)) {
        continue;
      }

      final candidate = _evaluateRuleSync(rule, params);
      if (candidate != null) {
        return candidate;
      }
    }

    return null;
  }

  ParsedTransaction? _evaluateTemplateSync(
    ExpenseTemplate template,
    EvaluateRulesParams params,
    dynamic monitoredSource,
  ) {
    try {
      // Direct RegExp usage in isolate (TimedRegex uses flutter/foundation.dart)
      final regex = RegExp(template.amountPattern);
      final allMatches = regex.allMatches(params.rawMessage).toList();

      Match? amountMatch;

      if (template.selectedAmount != null && allMatches.isNotEmpty) {
        final targetNormalized = _normalizeAmountForComparison(
          template.selectedAmount!,
        );
        Match? exactMatch;
        for (final m in allMatches) {
          final numericPortion = m.group(2) ?? m.group(0) ?? '';
          if (_normalizeAmountForComparison(numericPortion) ==
              targetNormalized) {
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
        final cleanAmount = amountStr.replaceAll(RegExp(r'[^\d.]'), '');
        amount = double.tryParse(cleanAmount);
      }

      if (amount == null) return null;

      String description = template.descriptionPattern ?? 'Template Expense';
      if (params.messageDate != null && monitoredSource != null) {
        description =
            '${monitoredSource.contactName} - ${params.messageDate!.toIso8601String()}';
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

  ParsedTransaction? _evaluateRuleSync(
    ParsingRule rule,
    EvaluateRulesParams params,
  ) {
    try {
      final regex = RegExp(rule.amountPattern);
      final amountMatch = regex.firstMatch(params.rawMessage);

      if (amountMatch == null) return null;

      double? amount;
      String? description;
      DateTime? date;

      final amountStr = amountMatch.group(1) ?? amountMatch.group(0);
      if (amountStr != null) {
        final cleanAmount = amountStr.replaceAll(RegExp(r'[^\d.]'), '');
        amount = double.tryParse(cleanAmount);
      }

      if (rule.datePattern != null) {
        final dateRegex = RegExp(rule.datePattern!);
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

  DateTime? _parseDate(String dateStr) {
    final datePatterns = [
      RegExp(r'(\d{2})/(\d{2})/(\d{4})'),
      RegExp(r'(\d{2})-(\d{2})-(\d{4})'),
      RegExp(r'(\d{4})/(\d{2})/(\d{2})'),
      RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(dateStr);
      if (match != null) {
        try {
          if (match.groupCount == 3) {
            if (dateStr.contains('/') || dateStr.contains('-')) {
              if (int.tryParse(match.group(1)!)! > 12) {
                final year = int.parse(match.group(1)!);
                final month = int.parse(match.group(2)!);
                final day = int.parse(match.group(3)!);
                return DateTime(year, month, day);
              } else {
                final month = int.parse(match.group(1)!);
                final day = int.parse(match.group(2)!);
                final year = int.parse(match.group(3)!);
                return DateTime(year, month, day);
              }
            }
          }
        } catch (_) {}
      }
    }
    return null;
  }
}
