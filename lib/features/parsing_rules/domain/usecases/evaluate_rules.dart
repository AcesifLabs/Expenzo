import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../../../../core/utils/regex_utils.dart';
import '../entities/parsing_rule.dart';
import '../entities/parsed_transaction.dart';
import '../repositories/parsing_rules_repository.dart';
import '../../../message_templates/domain/repositories/message_template_repository.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';

/// Pre-fetched context to avoid N+1 database queries during batch scanning.
/// Fetch all data once before scanning and pass this context to each evaluation.
class ParsingContext {
  final List<ParsingRule> rules;
  final List<ExpenseTemplate> templates;
  final List<MessageSource> sources;

  const ParsingContext({
    required this.rules,
    required this.templates,
    required this.sources,
  });
}

class EvaluateRulesUseCase
    implements UseCase<ParsedTransaction?, EvaluateRulesParams> {
  final ParsingRulesRepository rulesRepository;
  final MessageTemplateRepository templateRepository;

  EvaluateRulesUseCase(this.rulesRepository, this.templateRepository);

  /// Pre-fetches all rules, templates, and sources needed for batch scanning.
  /// Call this ONCE before scanning multiple messages, then pass the context
  /// to [evaluateWithPreloadedContext] for each message.
  Future<ParsingContext> loadContext() async {
    final rulesResult = await rulesRepository.getRules(isEnabled: true);
    final templatesResult = await templateRepository.getAllTemplates();
    final sourcesResult = await templateRepository.getMessageSources();

    final rules = rulesResult.getOrElse(() => []);
    final templates = templatesResult.getOrElse(() => []);
    final sources = sourcesResult.getOrElse(() => []);

    // Pre-sort rules by priority (highest first) once
    rules.sort((a, b) => b.priority.compareTo(a.priority));

    return ParsingContext(rules: rules, templates: templates, sources: sources);
  }

  /// Evaluates a single message using pre-loaded context (no DB queries).
  /// Use this during batch scanning for O(1) per-message overhead.
  ParsedTransaction? evaluateWithPreloadedContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    // 1. Check all user-defined templates across all monitored sources
    final monitoredSources = context.sources.cast<dynamic>().where((s) => s.isMonitored).toList();

    for (final source in monitoredSources) {
      final contactTemplates = context.templates
          .where((t) => t.sourceId == source.id)
          .toList();

      for (final template in contactTemplates) {
        final matchesTrigger = params.rawMessage.toLowerCase().contains(
          template.triggerWord.toLowerCase(),
        );
        debugPrint(
          'Checking template ${template.id} for source ${source.id}: '
          'Trigger: "${template.triggerWord}", Match: $matchesTrigger',
        );

        if (matchesTrigger) {
          final candidate = _evaluateTemplateSync(
            template,
            params,
            source,
          );
          if (candidate != null) {
            debugPrint('Template ${template.id} matched successfully!');
            return candidate;
          } else {
            debugPrint('Template ${template.id} trigger matched, but amount/pattern failed.');
          }
        }
      }
    }

    // 2. Fall back to global parsing rules (already sorted by priority)
    for (final rule in context.rules) {
      if (rule.sourceType == SourceType.sms && params.sourceType != 'sms') {
        continue;
      }
      if (rule.sourceType == SourceType.email && params.sourceType != 'email') {
        continue;
      }

      final matchesTrigger = rule.matchesTriggerWord(params.rawMessage);
      debugPrint('Checking global rule ${rule.id}: Trigger: ${rule.triggerWords}, Match: $matchesTrigger');

      if (!matchesTrigger) {
        continue;
      }

      final candidate = _evaluateRuleSync(rule, params);
      if (candidate != null) {
        debugPrint('Global rule ${rule.id} matched successfully!');
        return candidate;
      } else {
        debugPrint('Global rule ${rule.id} trigger matched, but amount/pattern failed.');
      }
    }

    return null;
  }

  @override
  Future<Either<Failure, ParsedTransaction?>> call(
    EvaluateRulesParams params,
  ) async {
    // Legacy path: loads context on each call (used for single-message evaluation)
    try {
      final context = await loadContext();
      final result = evaluateWithPreloadedContext(context, params);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  static String _normalizeAmountForComparison(String amount) {
    return amount.replaceAll(RegExp(r'[^\d.]'), '');
  }

  /// Synchronous template evaluation using pre-loaded context data.
  ParsedTransaction? _evaluateTemplateSync(
    ExpenseTemplate template,
    EvaluateRulesParams params,
    dynamic monitoredSource,
  ) {
    try {
      final timedRegex = TimedRegex(
        pattern: template.amountPattern,
        timeout: const Duration(seconds: 2),
      );

      final allMatches = timedRegex.allMatches(params.rawMessage).toList();

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

  /// Synchronous rule evaluation (no DB queries).
  ParsedTransaction? _evaluateRuleSync(
    ParsingRule rule,
    EvaluateRulesParams params,
  ) {
    try {
      final timedRegex = TimedRegex(
        pattern: rule.amountPattern,
        timeout: const Duration(seconds: 2),
      );

      final amountMatch = timedRegex.firstMatch(params.rawMessage);

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
        final dateRegex = TimedRegex(
          pattern: rule.datePattern!,
          timeout: const Duration(seconds: 2),
        );
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

class EvaluateRulesParams {
  final String rawMessage;
  final String sourceType;
  final String sourceId;
  final String? address;
  final DateTime? messageDate;

  EvaluateRulesParams({
    required this.rawMessage,
    required this.sourceType,
    required this.sourceId,
    this.address,
    this.messageDate,
  });
}
