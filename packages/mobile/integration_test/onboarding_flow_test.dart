import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/i18n/strings.g.dart';

import 'support/app.dart';

Future<void> _freshInstall() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  final dir = await getApplicationDocumentsDirectory();
  for (final suffix in ['', '-wal', '-shm']) {
    final file = File(p.join(dir.path, 'expenzo_db.sqlite$suffix'));
    if (file.existsSync()) file.deleteSync();
  }
}

Future<void> _settle(WidgetTester tester, [int seconds = 2]) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await hideKeyboard(tester);
  final target = find.text(text).last;
  await tester.ensureVisible(target);
  await _settle(tester, 1);
  await tester.tap(target);
  await _settle(tester);
}

Future<void> _continue(WidgetTester tester) =>
    _tapText(tester, t.onboarding.common.continueLabel);

void main() {
  patrolTest('a fresh install goes through onboarding to Home', ($) async {
    final tester = $.tester;
    await _freshInstall();
    await startApp(tester);
    LocaleSettings.setLocaleSync(AppLocale.en);
    await _settle(tester);

    expect(find.text(t.onboarding.income.title), findsOneWidget);
    await tester.enterText(find.byType(TextField), '5000');
    await _settle(tester, 1);
    await _continue(tester);

    await _tapText(tester, t.onboarding.recurring.addFirst);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Rent');
    await tester.enterText(fields.at(1), '1200');
    await _tapText(tester, t.common.add);
    expect(find.text(t.onboarding.recurring.total), findsOneWidget);

    await tester.tap(find.byTooltip(t.common.back));
    await _settle(tester);
    expect(find.text(t.onboarding.income.title), findsOneWidget);
    expect(find.widgetWithText(TextField, '5000'), findsOneWidget);
    await _continue(tester);
    await _continue(tester);

    expect(find.text(t.onboarding.plan.title), findsOneWidget);
    await _continue(tester);

    final goalFields = find.byType(TextField);
    await tester.enterText(goalFields.at(0), 'Laptop');
    await tester.enterText(goalFields.at(1), '1999');
    await _settle(tester, 1);
    await _continue(tester);

    final threeMonths = t.onboarding.timeline.months(n: 3);
    await _tapText(tester, threeMonths);

    await tester.scrollUntilVisible(
      find.text(t.onboarding.complete.title),
      200,
      scrollable: find
          .ancestor(
            of: find.text(threeMonths),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text(t.onboarding.complete.title), findsOneWidget);
    await _tapText(tester, t.onboarding.complete.finish);
    await _settle(tester, 3);

    await _tapText(tester, t.onboarding.common.skip);
    await _settle(tester, 3);

    final names = t.budgets.plan.names;
    for (final name in [names.needs, names.wants, names.savings]) {
      expect(find.text(name), findsWidgets, reason: name);
    }
    await tester.scrollUntilVisible(find.text('Laptop'), 200);
    expect(find.text(t.goals.card.addToGoal), findsOneWidget);

    final db = di.getIt<AppDatabase>();
    final recurring = await db.select(db.recurringTransactions).get();
    expect(recurring, hasLength(1));
    expect(recurring.single.nextOccurrence.isAfter(DateTime.now()), isTrue);
    expect(await db.select(db.records).get(), isEmpty);
    expect(await db.select(db.budgets).get(), hasLength(3));
    expect(await db.select(db.goals).get(), hasLength(1));
    final prefs = await SharedPreferences.getInstance();
    final settings = jsonDecode(prefs.getString('user_settings')!) as Map;
    expect(settings['onboardingCompleted'], isTrue);
    expect(settings['monthlyIncome'], 5000.0);

    await startApp(tester);
    expect(find.text(t.onboarding.income.title), findsNothing);
    await tester.scrollUntilVisible(find.text('Laptop'), 200);
    expect(find.text('Laptop'), findsWidgets);
  });
}
