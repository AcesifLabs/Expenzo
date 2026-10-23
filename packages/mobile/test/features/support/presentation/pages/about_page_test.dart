import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:expense_tracker/features/support/presentation/pages/about_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/pump_localized.dart';

void main() {
  final info = PackageInfo(
    appName: 'Expenzo',
    packageName: 'com.acesiflabs.expenzo',
    version: '1.2.3',
    buildNumber: '45',
  );

  testWidgets('shows the installed version and the description', (
    tester,
  ) async {
    await pumpLocalized(tester, AboutPage(loadInfo: () async => info));
    await tester.pumpAndSettle();

    expect(find.text('Version 1.2.3 (45)'), findsOneWidget);
    expect(find.text(t.support.about.description), findsOneWidget);
  });

  testWidgets('a failing platform call hides the version line', (tester) async {
    await pumpLocalized(
      tester,
      AboutPage(loadInfo: () => Future.error(Exception('no plugin'))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Version'), findsNothing);
    expect(find.text(t.support.about.description), findsOneWidget);
  });
}
