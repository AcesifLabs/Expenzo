import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 10, 5);

ParsingRule _rule(String id, String trigger, {String? datePattern}) =>
    ParsingRule(
      id: id,
      name: id,
      triggerWords: [trigger],
      amountPattern: r'Tk ([\d,.]+)',
      datePattern: datePattern,
      sourceType: SourceType.sms,
      isEnabled: true,
      priority: 1,
      createdAt: _at,
      updatedAt: _at,
    );

ParseMessageInput _sms(String id, String body) =>
    ParseMessageInput(body: body, address: 'BANK', date: _at, sourceId: id);

void main() {
  test('the deadline is 10 s plus 20 ms per message', () {
    expect(parseDeadline(0), const Duration(seconds: 10));
    expect(parseDeadline(100), const Duration(seconds: 12));
  });

  test('parses in an isolate: surest first, each message once, '
      'messages without an amount left out', () async {
    final parsed = await ParsingIsolateService().parseMessages(
      messages: [
        _sms('no-date', 'Tk 100.00 spent'),
        _sms('dated', 'Tk 200.00 debited on 05/10/2026'),
        _sms('dated', 'Tk 200.00 debited on 05/10/2026'),
        _sms('no-amount', 'debited, see your statement'),
      ],
      context: ParsingContext(
        rules: [
          _rule('dated', 'debited', datePattern: r'\d{2}/\d{2}/\d{4}'),
          _rule('plain', 'spent'),
        ],
        templates: const [],
        sources: const [],
      ),
      sourceType: AppSourceType.sms,
    );

    expect(parsed.map((p) => p.sourceId), ['dated', 'no-date']);
    expect(parsed.map((p) => p.confidenceScore), [1.0, 0.9]);
  });

  test('no messages, no isolate', () async {
    final parsed = await ParsingIsolateService().parseMessages(
      messages: const [],
      context: const ParsingContext(rules: [], templates: [], sources: []),
      sourceType: AppSourceType.sms,
    );

    expect(parsed, isEmpty);
  });
}
