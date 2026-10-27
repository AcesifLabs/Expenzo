import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/watched_sender.dart';
import '../repositories/message_template_repository.dart';

class GetSmsWatchlist implements UseCase<List<WatchedSender>, NoParams> {
  final MessageTemplateRepository repository;

  GetSmsWatchlist(this.repository);

  @override
  Future<Either<Failure, List<WatchedSender>>> call(NoParams params) async {
    final sources = await repository.getMessageSources();

    return sources.fold(Left.new, (sources) async {
      final templates = await repository.getAllTemplates();

      return templates.map((templates) {
        final counts = <String, int>{};
        for (final template in templates) {
          counts.update(template.sourceId, (n) => n + 1, ifAbsent: () => 1);
        }

        return [
          for (final source in sources)
            if ((counts[source.id] ?? 0) > 0)
              WatchedSender(source: source, formatCount: counts[source.id]!),
        ]..sort(
          (a, b) => a.source.contactName.toLowerCase().compareTo(
            b.source.contactName.toLowerCase(),
          ),
        );
      });
    });
  }
}
