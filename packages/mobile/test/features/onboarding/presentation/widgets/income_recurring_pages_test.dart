import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_income_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_recurring_page.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'onboarding_test_harness.dart';

void main() {
  setUpAll(registerOnboardingFallbacks);

  group('income page', () {
    Future<void> typeAmount(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    testWidgets('Continue waits for an amount above 0', (tester) async {
      await pumpOnboardingWidget(tester, const OnboardingIncomePage());

      expect(primaryButton(tester).onPressed, isNull);
      await typeAmount(tester, '0');
      expect(primaryButton(tester).onPressed, isNull);
      await typeAmount(tester, '5000');
      expect(primaryButton(tester).onPressed, isNotNull);
      await typeAmount(tester, '৫,০০০');
      expect(primaryButton(tester).onPressed, isNotNull);
    });

    testWidgets('Replay setup fills the saved income once it loads', (
      tester,
    ) async {
      final bloc = await pumpOnboardingWidget(
        tester,
        const OnboardingIncomePage(),
        storedIncome: 3000,
      );
      expect(find.widgetWithText(TextField, '3000'), findsNothing);

      bloc.add(const OnboardingStarted());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, CurrencyFormatter.formatInput(3000)),
        findsOneWidget,
      );
      expect(primaryButton(tester).onPressed, isNotNull);
    });

    testWidgets('a saved income never replaces what the user typed', (
      tester,
    ) async {
      final bloc = await pumpOnboardingWidget(
        tester,
        const OnboardingIncomePage(),
        storedIncome: 3000,
      );
      await typeAmount(tester, '42');

      bloc.add(const OnboardingStarted());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, '42'), findsOneWidget);
    });

    testWidgets('an amount above the maximum shows the error', (tester) async {
      await pumpOnboardingWidget(tester, const OnboardingIncomePage());

      await typeAmount(tester, '10000000000');

      expect(find.text(t.onboarding.income.amountInvalid), findsOneWidget);
      expect(primaryButton(tester).onPressed, isNull);
    });

    testWidgets('weekly shows the monthly amount', (tester) async {
      await pumpOnboardingWidget(tester, const OnboardingIncomePage());
      await typeAmount(tester, '1000');

      await tester.tap(find.text(t.onboarding.income.frequency.weekly));
      await tester.pump();

      expect(
        find.text(
          t.onboarding.income.perMonth(
            amount: CurrencyFormatter.format(52000 / 12),
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Continue submits the income', (tester) async {
      final bloc = await pumpOnboardingWidget(
        tester,
        const OnboardingIncomePage(),
      );
      await typeAmount(tester, '5000');

      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      expect(bloc.state.step, 1);
      expect(bloc.state.draft.monthlyIncome, 5000);
    });
  });

  group('recurring page', () {
    Future<void> addItem(
      WidgetTester tester,
      String name,
      String amount,
    ) async {
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), name);
      await tester.enterText(fields.at(1), amount);
      await tester.tap(find.text(t.common.add));
      await tester.pumpAndSettle();
    }

    testWidgets('the sheet starts at the default recurring frequency', (
      tester,
    ) async {
      await pumpOnboardingWidget(
        tester,
        const OnboardingRecurringPage(),
        settings: onboardingSettings(defaultRecurringFrequency: 'weekly'),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(find.text(RecurringFrequency.weekly.displayName), findsOneWidget);
    });

    testWidgets('adding an item shows its card and the total', (tester) async {
      final bloc = await pumpOnboardingWidget(
        tester,
        const OnboardingRecurringPage(),
      );

      await addItem(tester, 'Rent', '1200');

      expect(bloc.state.pendingRecurring.single.description, 'Rent');
      expect(find.textContaining('Rent'), findsOneWidget);
      expect(find.text(t.onboarding.recurring.total), findsOneWidget);
    });

    testWidgets('the delete button removes the card', (tester) async {
      final bloc = await pumpOnboardingWidget(
        tester,
        const OnboardingRecurringPage(),
        events: const [
          RecurringItemAdded(
            RecurringDraft(
              description: 'Netflix',
              amount: 15.49,
              frequency: RecurringFrequency.monthly,
            ),
          ),
        ],
      );

      await tester.tap(
        find.byTooltip(t.onboarding.recurring.remove(name: 'Netflix')),
      );
      await tester.pumpAndSettle();

      expect(bloc.state.pendingRecurring, isEmpty);
      expect(find.text(t.onboarding.recurring.total), findsNothing);
    });
  });
}
