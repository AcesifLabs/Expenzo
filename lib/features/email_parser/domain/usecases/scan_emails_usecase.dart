import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import '../../../parsing_rules/domain/usecases/evaluate_rules.dart';
import '../../domain/services/gmail_service.dart';

class ScanEmailsUseCase
    implements UseCase<List<ParsedTransaction>, ScanEmailsParams> {
  final GmailService gmailService;
  final EvaluateRulesUseCase evaluateRules;

  ScanEmailsUseCase({required this.gmailService, required this.evaluateRules});

  @override
  Future<Either<Failure, List<ParsedTransaction>>> call(
    ScanEmailsParams params,
  ) async {
    try {
      // Fetch emails - 50 default, configurable
      final maxResults = params.maxResults ?? 50;

      final emailsResult = await gmailService.getEmails(maxResults: maxResults);

      return emailsResult.fold((failure) => Left(failure), (emails) async {
        final List<ParsedTransaction> results = [];
        final processedIds = <String>{};

        // Filter to last 30 days
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final recentEmails = emails
            .where((e) => e.date.isAfter(thirtyDaysAgo))
            .toList();

        // Process 10 at a time (simulated via batching)
        for (var i = 0; i < recentEmails.length; i += 10) {
          final batch = recentEmails.skip(i).take(10).toList();

          for (final email in batch) {
            // Generate sourceId from message ID
            final sourceId = 'email_${email.id.hashCode.abs()}';

            // Skip duplicates
            if (processedIds.contains(sourceId)) continue;
            processedIds.add(sourceId);

            // Combine subject and body for parsing
            final rawMessage =
                '${email.subject ?? ''} ${email.bodyPlain ?? ''}';

            // Evaluate rules
            final result = await evaluateRules(
              EvaluateRulesParams(
                rawMessage: rawMessage,
                sourceType: 'email',
                sourceId: sourceId,
                address: email.from,
                messageDate: email.date,
              ),
            );

            result.fold((failure) {}, (parsed) {
              if (parsed != null &&
                  !parsed.parseFailed &&
                  parsed.amount != null) {
                results.add(parsed);
              }
            });
          }
        }

        // Sort by confidence (highest first)
        results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

        return Right(results);
      });
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}

class ScanEmailsParams {
  final int? maxResults;

  ScanEmailsParams({this.maxResults});
}
