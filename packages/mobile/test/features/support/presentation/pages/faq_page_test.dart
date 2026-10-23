import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/support/domain/faq_entry.dart';
import 'package:expense_tracker/features/support/presentation/pages/faq_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_search_bar.dart';

import '../../../../support/pump_localized.dart';

void main() {
  Future<void> pumpFaq(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(tester, const FaqPage());
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(AppSearchBar), query);
    await tester.pumpAndSettle();
  }

  testWidgets('shows every question, with only the first answer open', (
    tester,
  ) async {
    await pumpFaq(tester);
    final entries = faqEntries();

    for (final entry in entries) {
      expect(find.text(entry.question), findsOneWidget);
    }
    expect(find.text(entries.first.answer), findsOneWidget);
    expect(find.text(entries[1].answer), findsNothing);
  });

  testWidgets('searching "budget" leaves the budget question', (tester) async {
    await pumpFaq(tester);

    await search(tester, 'budget');

    expect(find.text(t.support.faq.budget.q), findsOneWidget);
    expect(find.text(t.support.faq.currency.q), findsNothing);
  });

  testWidgets('a search with no match shows the no-results text', (
    tester,
  ) async {
    await pumpFaq(tester);

    await search(tester, 'zzzz');

    expect(find.text(t.support.faq.noResults(query: 'zzzz')), findsOneWidget);
  });

  testWidgets('tapping a closed question shows its answer', (tester) async {
    await pumpFaq(tester);

    await tester.tap(find.text(t.support.faq.export.q));
    await tester.pumpAndSettle();

    expect(find.text(t.support.faq.export.a), findsOneWidget);
  });
}
