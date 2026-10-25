import 'dart:developer' show log;

import 'package:expense_tracker/core/utils/isolate_deadline.dart';
import '../entities/parsed_transaction.dart';
import '../entities/parsing_rule.dart';
import '../entities/evaluate_rules_params.dart';
import '../entities/parsing_context.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';
import '../services/rule_evaluator.dart';

/// Time a parse may take before its isolate is killed: generous for a full
/// inbox, short enough that a broken user regex doesn't hang the scan.
Duration parseDeadline(int messageCount) =>
    Duration(seconds: 10, milliseconds: 20 * messageCount);

class ParsingIsolateService {
  /// Throws a `TimeoutException` when parsing passes [parseDeadline], which
  /// in practice means a matching rule's pattern backtracks forever.
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

    return runWithDeadline(
      () => _parseInIsolate(payload),
      parseDeadline(messages.length),
    );
  }
}

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

void _isolateLog(String message) {
  log(message, name: 'ParsingIsolate');
}

List<ParsedTransaction> _parseInIsolate(_IsolatePayload payload) {
  final context = ParsingContext(
    rules: payload.rules,
    templates: payload.templates,
    sources: payload.sources,
  ).withPrecompiledRegex();

  final results = <ParsedTransaction>[];
  final processedIds = <String>{};

  for (final message in payload.messages) {
    if (processedIds.contains(message.sourceId)) continue;
    processedIds.add(message.sourceId);

    _isolateLog(
      'Evaluating message ${message.sourceId} (length: ${message.body.length})',
    );

    final parsed = RuleEvaluator.evaluateWithContext(
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
      _isolateLog('Message matched: ${message.sourceId}');
      results.add(parsed);
    }
  }

  results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

  return results;
}
