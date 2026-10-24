import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';

import '../../domain/entities/group_summary.dart';

/// Reads a Shared Budget's spent from the cached group summary. A summary
/// counted for an earlier period (it rolled over since) gives null, so the
/// caller falls back to local data rather than show last period's spend.
SharedSpentLookup sharedSpentFromSummary(GroupSummary? Function() summary) {
  return (budgetId, periodStart) {
    final progress = summary()?.budget(budgetId);
    if (progress == null) return null;
    final server = progress.periodStart.toLocal();
    final sameDay =
        server.year == periodStart.year &&
        server.month == periodStart.month &&
        server.day == periodStart.day;

    return sameDay ? progress.spent : null;
  };
}
