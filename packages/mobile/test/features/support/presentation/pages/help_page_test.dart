import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/router/help_route.dart';
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/features/support/presentation/pages/help_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/pump_localized.dart';

void main() {
  /// Help & Support at its real location, with a stub page per Help route.
  Future<void> pumpHelp(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: SettingsRoute.help.location,
      routes: [
        GoRoute(
          path: SettingsRoute.help.location,
          builder: (_, _) => const HelpPage(),
          routes: [
            for (final route in HelpRoute.values)
              GoRoute(
                path: route.path,
                builder: (_, _) => Text('${route.name}-page'),
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      translated(MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the six rows in order and no Watch tutorial', (
    tester,
  ) async {
    await pumpHelp(tester);
    final helpT = t.support.help;

    final titles = [
      helpT.faq,
      helpT.contactSupport,
      helpT.rateApp,
      helpT.privacyPolicy,
      helpT.termsOfService,
      helpT.about,
    ];
    final tops = [
      for (final title in titles) tester.getTopLeft(find.text(title)).dy,
    ];
    expect(tops, [...tops]..sort());
    expect(find.textContaining('tutorial'), findsNothing);
  });

  for (final (label, route) in [
    ('FAQ', HelpRoute.faq),
    ('Rate the app', HelpRoute.rate),
    ('About', HelpRoute.about),
  ]) {
    testWidgets('$label opens ${route.location}', (tester) async {
      await pumpHelp(tester);

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(find.text('${route.name}-page'), findsOneWidget);
    });
  }
}
