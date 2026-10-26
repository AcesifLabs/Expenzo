import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/parsing_rules/data/datasources/default_rules_templates.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/evaluate_rules_params.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/rule_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

void main() {
  final context = ParsingContext(
    rules: [
      for (final template in DefaultRulesTemplates.templates)
        template.toParsingRule(),
    ],
    templates: const [],
    sources: const [],
  );

  final triggers = DefaultRulesTemplates.templates
      .expand((t) => t.triggerWords)
      .join(' ');

  property('the default rules never throw and finish within the deadline', () {
    forAll(smsNoise(maxLength: 400), maxExamples: propertyTrials, (noise) {
      final watch = Stopwatch()..start();
      final parsed = RuleEvaluator.evaluateWithContext(
        context,
        EvaluateRulesParams(
          rawMessage: '$triggers Rs. $noise INR $noise',
          sourceType: AppSourceType.sms,
          sourceId: 'sms-1',
        ),
      );
      expect(watch.elapsed, lessThan(parseDeadline(1)));
      final amount = parsed?.amount;
      if (amount != null) expect(amount, greaterThan(0));
    });
  });
}
