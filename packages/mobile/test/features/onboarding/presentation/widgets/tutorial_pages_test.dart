import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/tutorial_pages.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/pump_localized.dart';

void main() {
  Future<int> pumpTutorial(WidgetTester tester, {ThemeData? theme}) async {
    var done = 0;
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(
      tester,
      Scaffold(body: TutorialPages(onDone: () => done++)),
      theme: theme,
    );
    await tester.pumpAndSettle();

    return done;
  }

  testWidgets('starts on the dashboard page', (tester) async {
    await pumpTutorial(tester);

    expect(find.text(t.onboarding.tutorial.dashboard.title), findsOneWidget);
  });

  testWidgets('Next three times reaches the CTA, whose button finishes', (
    tester,
  ) async {
    var done = 0;
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(
      tester,
      Scaffold(body: TutorialPages(onDone: () => done++)),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text(t.common.next));
      await tester.pumpAndSettle();
    }
    expect(find.text(t.onboarding.tutorial.cta.title), findsOneWidget);

    await tester.tap(find.text(t.onboarding.tutorial.cta.start));
    expect(done, 1);
  });

  testWidgets('Skip finishes once', (tester) async {
    var done = 0;
    await pumpLocalized(
      tester,
      Scaffold(body: TutorialPages(onDone: () => done++)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.common.skip));

    expect(done, 1);
  });

  testWidgets('a dark theme shows the dark screenshot', (tester) async {
    await pumpTutorial(tester, theme: AppTheme.darkTheme);

    final image = tester.widget<Image>(find.byType(Image).first);
    expect(
      (image.image as AssetImage).assetName,
      tutorialPages.first.darkAsset,
    );
  });

  test('every screenshot is bundled', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final page in tutorialPages) {
      for (final path in [page.lightAsset, page.darkAsset]) {
        expect(
          (await rootBundle.load(path)).lengthInBytes,
          greaterThan(0),
          reason: path,
        );
      }
    }
  });
}
