import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/income_frequency.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_result.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/tutorial_pages.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/pump_localized.dart';

class _MockComplete extends Mock implements CompleteOnboarding {}

class _MockGetSettings extends Mock implements GetSettings {}

UserSettings settingsFixture() => UserSettings(
  currencyCode: 'BDT',
  emailFetchLimit: 100,
  notificationsEnabled: true,
  theme: 'system',
  onboardingCompleted: false,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  late _MockComplete complete;
  late OnboardingBloc bloc;

  setUpAll(() {
    registerFallbackValue(const OnboardingDraft());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    complete = _MockComplete();
    when(
      () => complete(any()),
    ).thenAnswer((_) async => const Right(OnboardingResult()));
    di.getIt.registerSingleton<SettingsBloc>(
      mockBloc<MockSettingsBloc, SettingsState>(
        MockSettingsBloc(),
        const SettingsInitial(),
      ),
    );
  });

  tearDown(() => di.getIt.reset());

  Future<void> pumpOnboarding(WidgetTester tester) async {
    final getSettings = _MockGetSettings();
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(settingsFixture()));
    bloc = OnboardingBloc(
      completeOnboarding: complete,
      getSettings: getSettings,
    );
    addTearDown(bloc.close);
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Text('home'),
          routes: [
            GoRoute(
              path: 'onboarding',
              builder: (_, _) => BlocProvider.value(
                value: bloc,
                child: const OnboardingPage(),
              ),
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

  Finder backButton() => find.byTooltip(t.common.back);

  testWidgets('no back button on the first step; from step 2 it goes back', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    expect(backButton(), findsNothing);

    bloc.add(const IncomeSubmitted(5000, IncomeFrequency.monthly));
    await tester.pumpAndSettle();
    expect(bloc.state.step, 1);

    await tester.tap(backButton());
    await tester.pumpAndSettle();

    expect(bloc.state.step, 0);
    expect(backButton(), findsNothing);
  });

  testWidgets(
    'system back goes to the previous step, and does nothing on the first',
    (tester) async {
      await pumpOnboarding(tester);
      bloc.add(const IncomeSubmitted(5000, IncomeFrequency.monthly));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(bloc.state.step, 0);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(bloc.state.step, 0);
      expect(find.text('home'), findsNothing);
    },
  );

  testWidgets('Skip saves once, then the tutorial leads Home', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text(t.onboarding.common.skip));
    await tester.pumpAndSettle();

    verify(() => complete(any())).called(1);
    verify(() => di.getIt<SettingsBloc>().add(const LoadSettings())).called(1);
    expect(find.byType(TutorialPages), findsOneWidget);

    await tester.tap(find.text(t.onboarding.common.skip));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
