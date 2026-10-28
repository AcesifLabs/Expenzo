import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 10, 5);

final _bank = MessageSource(
  id: 'src-bank',
  contactId: 'BANK',
  contactName: 'Bank',
  isMonitored: true,
  createdAt: _at,
  updatedAt: _at,
);

ExpenseTemplate _template(String id, String trigger) => ExpenseTemplate(
  id: id,
  sourceId: _bank.id,
  sampleMessage: 'sample',
  triggerWord: trigger,
  amountPattern: r'Tk ([\d,.]+)',
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

  test('parses in an isolate: each message once, messages without an '
      'amount left out', () async {
    final parsed = await ParsingIsolateService().parseMessages(
      messages: [
        _sms('spent', 'Tk 100.00 spent'),
        _sms('debit', 'Tk 200.00 debited on 05/10/2026'),
        _sms('debit', 'Tk 200.00 debited on 05/10/2026'),
        _sms('no-amount', 'debited, see your statement'),
      ],
      context: ParsingContext(
        templates: [
          _template('t-debit', 'debited'),
          _template('t-spent', 'spent'),
        ],
        sources: [_bank],
      ),
      sourceType: AppSourceType.sms,
    );

    expect(parsed.map((p) => p.sourceId), ['spent', 'debit']);
    expect(parsed.map((p) => p.amount), [100, 200]);
  });

  test('no messages, no isolate', () async {
    final parsed = await ParsingIsolateService().parseMessages(
      messages: const [],
      context: const ParsingContext(templates: [], sources: []),
      sourceType: AppSourceType.sms,
    );

    expect(parsed, isEmpty);
  });
}
