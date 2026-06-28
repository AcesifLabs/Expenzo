import 'dart:isolate';
import 'dart:developer' show log;
import '../entities/parsed_transaction.dart';
import '../entities/parsing_rule.dart';
import '../entities/parsing_types.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';
import '../services/rule_evaluator.dart';

class ParsingIsolateService {
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

    return Isolate.run(() => _parseInIsolate(payload));
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
      'Evaluating message from ${message.address}: "${message.body}"',
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
      _isolateLog(
        'Message matched! Amount: ${parsed.amount}, Category: ${parsed.categoryId}',
      );
      results.add(parsed);
    }
  }

  results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
  return results;
}
