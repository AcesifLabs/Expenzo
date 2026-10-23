import 'package:equatable/equatable.dart';

import 'package:expense_tracker/i18n/strings.g.dart';

/// One question on the FAQ screen, in the current language.
class FaqEntry extends Equatable {
  /// Stable across languages, e.g. `addTransaction`.
  final String id;
  final String question;
  final String answer;

  @override
  List<Object?> get props => [id, question, answer];

  const FaqEntry({
    required this.id,
    required this.question,
    required this.answer,
  });
}

/// Built on each call so it follows the current language. Full `t.` paths,
/// not an alias: `slang analyze` only sees full paths (ADR 0007).
List<FaqEntry> faqEntries() => [
  FaqEntry(
    id: 'addTransaction',
    question: t.support.faq.addTransaction.q,
    answer: t.support.faq.addTransaction.a,
  ),
  FaqEntry(
    id: 'autoImport',
    question: t.support.faq.autoImport.q,
    answer: t.support.faq.autoImport.a,
  ),
  FaqEntry(
    id: 'budget',
    question: t.support.faq.budget.q,
    answer: t.support.faq.budget.a,
  ),
  FaqEntry(
    id: 'recurring',
    question: t.support.faq.recurring.q,
    answer: t.support.faq.recurring.a,
  ),
  FaqEntry(
    id: 'export',
    question: t.support.faq.export.q,
    answer: t.support.faq.export.a,
  ),
  FaqEntry(
    id: 'sync',
    question: t.support.faq.sync.q,
    answer: t.support.faq.sync.a,
  ),
  FaqEntry(
    id: 'aiAssistant',
    question: t.support.faq.aiAssistant.q,
    answer: t.support.faq.aiAssistant.a,
  ),
  FaqEntry(
    id: 'currency',
    question: t.support.faq.currency.q,
    answer: t.support.faq.currency.a,
  ),
];

/// Case-insensitive match on question or answer; a blank query returns all.
List<FaqEntry> filterFaqEntries(List<FaqEntry> entries, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return entries;

  return entries
      .where(
        (entry) =>
            entry.question.toLowerCase().contains(needle) ||
            entry.answer.toLowerCase().contains(needle),
      )
      .toList();
}
