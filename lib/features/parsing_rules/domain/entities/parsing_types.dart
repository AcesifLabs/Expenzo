import '../entities/parsing_rule.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';

class ParsingContext {
  final List<ParsingRule> rules;
  final List<ExpenseTemplate> templates;
  final List<MessageSource> sources;
  final Map<String, RegExp> regexCache;

  const ParsingContext({
    required this.rules,
    required this.templates,
    required this.sources,
    this.regexCache = const {},
  });

  ParsingContext withPrecompiledRegex() {
    final cache = <String, RegExp>{};
    for (final rule in rules) {
      cache[rule.amountPattern] = RegExp(rule.amountPattern);
      if (rule.datePattern != null) {
        cache[rule.datePattern!] = RegExp(rule.datePattern!);
      }
    }
    for (final template in templates) {
      cache[template.amountPattern] = RegExp(template.amountPattern);
      if (template.datePattern != null) {
        cache[template.datePattern!] = RegExp(template.datePattern!);
      }
    }
    return ParsingContext(
      rules: rules,
      templates: templates,
      sources: sources,
      regexCache: cache,
    );
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
