import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../../../../core/utils/regex_utils.dart';
import '../entities/parsing_rule.dart';
import '../entities/parsed_transaction.dart';
import '../repositories/parsing_rules_repository.dart';
import '../../../message_templates/domain/repositories/message_template_repository.dart';
import '../../../message_templates/domain/entities/expense_template.dart';

class EvaluateRulesUseCase
    implements UseCase<ParsedTransaction?, EvaluateRulesParams> {
  final ParsingRulesRepository rulesRepository;
  final MessageTemplateRepository templateRepository;

  EvaluateRulesUseCase(this.rulesRepository, this.templateRepository);

  @override
  Future<Either<Failure, ParsedTransaction?>> call(
    EvaluateRulesParams params,
  ) async {
    // First check user-defined templates
    final templatesResult = await templateRepository.getAllTemplates();
    final sourcesResult = await templateRepository.getMessageSources();

    // If templates exist and contact matches
    if (templatesResult.isRight() && sourcesResult.isRight()) {
      final templates = templatesResult.getOrElse(() => []);
      final sources = sourcesResult.getOrElse(() => []);

      // Check if this contact/address is monitored
      final monitoredSource = sources.cast<dynamic>().firstWhere(
        (s) => s.contactId == params.address && s.isMonitored,
        orElse: () => null,
      );

      if (monitoredSource != null) {
        final contactTemplates = templates
            .where((t) => t.sourceId == monitoredSource.id)
            .toList();

        for (final template in contactTemplates) {
          // Explicitly check for the triggerWord the user selected
          if (params.rawMessage.toLowerCase().contains(
            template.triggerWord.toLowerCase(),
          )) {
            final candidate = await _evaluateTemplate(template, params);
            if (candidate != null) {
              return Right(candidate);
            }
          }
        }

        // If source has templates configured, only use those - no global rules fallback
        if (contactTemplates.isNotEmpty) {
          return const Right(null);
        }
      }
    }

    // Fall back to global parsing rules ONLY if source has no templates
    final rulesResult = await rulesRepository.getRules(
      sourceType: params.sourceType == 'sms'
          ? SourceType.sms
          : params.sourceType == 'email'
          ? SourceType.email
          : null,
      isEnabled: true,
    );

    return rulesResult.fold((failure) => Left(failure), (rules) async {
      rules.sort((a, b) => b.priority.compareTo(a.priority));

      for (final rule in rules) {
        if (rule.sourceType == SourceType.sms && params.sourceType != 'sms') {
          continue;
        }
        if (rule.sourceType == SourceType.email &&
            params.sourceType != 'email') {
          continue;
        }

        if (!rule.matchesTriggerWord(params.rawMessage)) {
          continue;
        }

        final candidate = await _evaluateRule(rule, params);
        if (candidate != null) {
          return Right(candidate);
        }
      }

      return const Right(null);
    });
  }

  static String _normalizeAmountForComparison(String amount) {
    return amount.replaceAll(RegExp(r'[^\d.]'), '');
  }

  Future<ParsedTransaction?> _evaluateTemplate(
    ExpenseTemplate template,
    EvaluateRulesParams params,
  ) async {
    final sourcesResult = await templateRepository.getMessageSources();
    final sources = sourcesResult.getOrElse(() => []);
    final monitoredSource = sources.cast<dynamic>().firstWhere(
      (s) => s.id == template.sourceId,
      orElse: () => null,
    );

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
        // Try to find a match with the same numeric value as selectedAmount
        // This helps disambiguate when multiple amounts exist in a message
        Match? exactMatch;
        for (final m in allMatches) {
          // Group 2 is the numeric portion (without currency prefix) if pattern has 2 groups
          final numericPortion = m.group(2) ?? m.group(0) ?? '';
          if (_normalizeAmountForComparison(numericPortion) ==
              targetNormalized) {
            exactMatch = m;
            break;
          }
        }
        // Use the exact match if found, otherwise fall back to first match
        // (selectedAmount is a hint, not a strict filter - the pattern should generalize)
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
        confidenceScore: 0.95, // High confidence for custom templates
        matchedRuleId: template.id,
        parseFailed: false,
        parseError: null,
      );
    } catch (e) {
      return null;
    }
  }

  Future<ParsedTransaction?> _evaluateRule(
    ParsingRule rule,
    EvaluateRulesParams params,
  ) async {
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
