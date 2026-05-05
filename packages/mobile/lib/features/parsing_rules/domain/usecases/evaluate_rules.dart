import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/parsed_transaction.dart';
import '../entities/parsing_types.dart';
import '../repositories/parsing_rules_repository.dart';
import '../../../message_templates/domain/repositories/message_template_repository.dart';
import '../services/rule_evaluator.dart';

class EvaluateRulesUseCase
    implements UseCase<ParsedTransaction?, EvaluateRulesParams> {
  final ParsingRulesRepository rulesRepository;
  final MessageTemplateRepository templateRepository;

  EvaluateRulesUseCase(this.rulesRepository, this.templateRepository);

  /// Pre-fetches all rules, templates, and sources needed for batch scanning.
  Future<ParsingContext> loadContext() async {
    final rulesResult = await rulesRepository.getRules(isEnabled: true);
    final templatesResult = await templateRepository.getAllTemplates();
    final sourcesResult = await templateRepository.getMessageSources();

    final rules = rulesResult.getOrElse(() => []);
    final templates = templatesResult.getOrElse(() => []);
    final sources = sourcesResult.getOrElse(() => []);

    // Pre-sort rules by priority (highest first) once
    rules.sort((a, b) => b.priority.compareTo(a.priority));

    return ParsingContext(
      rules: rules,
      templates: templates,
      sources: sources,
    ).withPrecompiledRegex();
  }

  /// Evaluates a single message using pre-loaded context (no DB queries).
  ParsedTransaction? evaluateWithPreloadedContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    return RuleEvaluator.evaluateWithContext(context, params);
  }

  @override
  Future<Either<Failure, ParsedTransaction?>> call(
    EvaluateRulesParams params,
  ) async {
    try {
      final context = await loadContext();
      final result = evaluateWithPreloadedContext(context, params);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
