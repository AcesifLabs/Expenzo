import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/locale_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Label extends StatelessWidget {
  const _Label();

  // Reads the global `t`, not context.t, like the app's widgets.
  @override
  Widget build(BuildContext context) => Text(t.settings.language.title);
}

void main() {
  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  testWidgets('switching language rebuilds text read from the global t', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    await tester.pumpWidget(
      const MaterialApp(
        home: LocaleScope(child: Scaffold(body: _Label())),
      ),
    );
    expect(find.text('Language'), findsOneWidget);

    LocaleSettings.setLocaleSync(AppLocale.bn);
    await tester.pump();

    expect(find.text('ভাষা'), findsOneWidget);
  });
}
