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
      final rdp = rule.datePattern;
      if (rdp != null) {
        cache[rdp] = RegExp(rdp);
      }
    }
    for (final template in templates) {
      cache[template.amountPattern] = RegExp(template.amountPattern);
      final tdp = template.datePattern;
      if (tdp != null) {
        cache[tdp] = RegExp(tdp);
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
