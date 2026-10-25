import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/evaluate_rules_params.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/rule_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 10, 5, 9, 30);

final _bank = MessageSource(
  id: 'src-bank',
  contactId: '16216',
  contactName: 'Bank',
  isMonitored: true,
  createdAt: _at,
  updatedAt: _at,
);

ExpenseTemplate _template(String id, String trigger, String pattern) =>
    ExpenseTemplate(
      id: id,
      sourceId: _bank.id,
      sampleMessage: 'sample',
      triggerWord: trigger,
      amountPattern: pattern,
      createdAt: _at,
      updatedAt: _at,
    );

ParsingRule _rule({
  SourceType sourceType = SourceType.sms,
  String? datePattern,
}) => ParsingRule(
  id: 'rule-${sourceType.name}',
  name: 'Debits',
  triggerWords: const ['debited'],
  amountPattern: r'Tk ([\d,.]+)',
  datePattern: datePattern,
  sourceType: sourceType,
  isEnabled: true,
  priority: 1,
  createdAt: _at,
  updatedAt: _at,
);

ParsedTransaction? _evaluate(
  String message, {
  List<ParsingRule> rules = const [],
  List<ExpenseTemplate> templates = const [],
  String sourceType = AppSourceType.sms,
}) => RuleEvaluator.evaluateWithContext(
  ParsingContext(rules: rules, templates: templates, sources: [_bank]),
  EvaluateRulesParams(
    rawMessage: message,
    sourceType: sourceType,
    sourceId: 'msg-1',
    address: _bank.contactId,
    messageDate: _at,
  ),
);

void main() {
  group('templates of a watched sender', () {
    test('a template that finds no amount gives way to the next', () {
      final parsed = _evaluate(
        'Tk 450.00 debited from A/C',
        templates: [
          _template('t-empty', 'debited', r'USD ([\d.]+)'),
          _template('t-tk', 'debited', r'Tk ([\d,.]+)'),
        ],
      );

      expect(parsed?.matchedRuleId, 't-tk');
      expect(parsed?.amount, 450);
      expect(parsed?.confidenceScore, 0.95);
      expect(parsed?.description, 'Bank - 05 Oct 2026 at 09:30');
    });

    test('an amount the template can\'t read is no transaction', () {
      final parsed = _evaluate(
        'Tk 0.00 debited from A/C',
        templates: [_template('t-tk', 'debited', r'Tk ([\d,.]+)')],
      );

      expect(parsed, isNull);
    });
  });

  group('rules', () {
    test('an SMS rule ignores email; an email rule reads only email', () {
      const message = 'Tk 500.00 debited';

      expect(_evaluate(message, rules: [_rule()]), isNotNull);
      expect(
        _evaluate(message, rules: [_rule()], sourceType: AppSourceType.email),
        isNull,
      );
      expect(
        _evaluate(message, rules: [_rule(sourceType: SourceType.email)]),
        isNull,
      );
      expect(
        _evaluate(
          message,
          rules: [_rule(sourceType: SourceType.email)],
          sourceType: AppSourceType.email,
        )?.amount,
        500,
      );
    });

    test('a rule that finds the date is surer than one that doesn\'t', () {
      const message = 'Tk 500.00 debited on 05/10/2026';

      expect(_evaluate(message, rules: [_rule()])?.confidenceScore, 0.9);
      expect(
        _evaluate(
          message,
          rules: [_rule(datePattern: r'\d{2}/\d{2}/\d{4}')],
        )?.confidenceScore,
        1.0,
      );
    });
  });
}
