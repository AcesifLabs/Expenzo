import 'package:equatable/equatable.dart';
import '../../../message_templates/domain/entities/expense_template.dart';
import '../../../message_templates/domain/entities/message_source.dart';

class ParsingContext extends Equatable {
  final List<ExpenseTemplate> templates;
  final List<MessageSource> sources;
  final Map<String, RegExp> regexCache;

  @override
  List<Object?> get props => [templates, sources, regexCache];

  const ParsingContext({
    required this.templates,
    required this.sources,
    this.regexCache = const {},
  });

  ParsingContext withPrecompiledRegex() {
    final cache = <String, RegExp>{};
    for (final template in templates) {
      cache[template.amountPattern] = RegExp(template.amountPattern);
      final tdp = template.datePattern;
      if (tdp != null) {
        cache[tdp] = RegExp(tdp);
      }
    }

    return ParsingContext(
      templates: templates,
      sources: sources,
      regexCache: cache,
    );
  }
}
