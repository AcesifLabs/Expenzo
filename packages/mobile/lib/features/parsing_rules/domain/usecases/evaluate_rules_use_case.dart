import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../entities/parsed_transaction.dart';
import '../entities/evaluate_rules_params.dart';
import '../entities/parsing_context.dart';
import '../../../message_templates/domain/repositories/message_template_repository.dart';
import '../services/rule_evaluator.dart';

class EvaluateRulesUseCase
    implements UseCase<ParsedTransaction?, EvaluateRulesParams> {
  final MessageTemplateRepository templateRepository;

  EvaluateRulesUseCase(this.templateRepository);

  Future<ParsingContext> loadContext() async {
    final templatesResult = await templateRepository.getAllTemplates();
    final sourcesResult = await templateRepository.getMessageSources();

    final templates = templatesResult.getOrElse(() => []);
    final sources = sourcesResult.getOrElse(() => []);

    return ParsingContext(
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

  @override
  Future<Either<Failure, ParsedTransaction?>> call(
    EvaluateRulesParams params,
  ) async {
    try {
      final context = await loadContext();
      final result = evaluateWithPreloadedContext(context, params);

      return Right(result);
    } catch (e, s) {
      appLogger.error('Error evaluating rules use case', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }
}
