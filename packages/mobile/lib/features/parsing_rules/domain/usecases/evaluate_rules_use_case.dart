import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/parsed_transaction.dart';
import '../entities/evaluate_rules_params.dart';
import '../entities/parsing_context.dart';
import '../repositories/parsing_rules_repository.dart';
import '../../../message_templates/domain/repositories/message_template_repository.dart';
import '../services/rule_evaluator.dart';

class EvaluateRulesUseCase
    implements UseCase<ParsedTransaction?, EvaluateRulesParams> {
  final ParsingRulesRepository rulesRepository;
  final MessageTemplateRepository templateRepository;

  EvaluateRulesUseCase(this.rulesRepository, this.templateRepository);

  Future<ParsingContext> loadContext() async {
    final rulesResult = await rulesRepository.getRules(isEnabled: true);
    final templatesResult = await templateRepository.getAllTemplates();
    final sourcesResult = await templateRepository.getMessageSources();

    final rules = rulesResult.getOrElse(() => []);
    final templates = templatesResult.getOrElse(() => []);
    final sources = sourcesResult.getOrElse(() => []);

    rules.sort((a, b) => b.priority.compareTo(a.priority));

    return ParsingContext(
      rules: rules,
      templates: templates,
      sources: sources,
    ).withPrecompiledRegex();
  }

  ParsedTransaction? evaluateWithPreloadedContext(
    ParsingContext context,
    EvaluateRulesParams params,
  ) {
    return RuleEvaluator.evaluateWithContext(context, params);
  }

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, ParsedTransaction?>> call(
    EvaluateRulesParams params,
  ) async {
    try {
      final context = await loadContext();
      final result = evaluateWithPreloadedContext(context, params);

      return Right(result);
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
