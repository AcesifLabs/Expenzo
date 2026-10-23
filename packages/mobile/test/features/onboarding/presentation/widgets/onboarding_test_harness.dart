import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_result.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/pump_localized.dart';

class MockCompleteOnboarding extends Mock implements CompleteOnboarding {}

class _MockGetSettings extends Mock implements GetSettings {}

UserSettings onboardingSettings({
  String defaultRecurringFrequency = 'monthly',
  double? monthlyIncome,
}) => UserSettings(
  currencyCode: 'BDT',
  emailFetchLimit: 100,
  notificationsEnabled: true,
  theme: 'system',
  defaultRecurringFrequency: defaultRecurringFrequency,
  onboardingCompleted: false,
  monthlyIncome: monthlyIncome,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void registerOnboardingFallbacks() {
  registerFallbackValue(const OnboardingDraft());
  registerFallbackValue(NoParams());
}

/// A real [OnboardingBloc] on a mocked [CompleteOnboarding], made inside the
/// test zone so its stream reaches the widgets. [events] set the draft up.
Future<OnboardingBloc> pumpOnboardingWidget(
  WidgetTester tester,
  Widget page, {
  MockCompleteOnboarding? complete,
  List<OnboardingEvent> events = const [],
  UserSettings? settings,
  double? storedIncome,
}) async {
  final completeOnboarding = complete ?? MockCompleteOnboarding();
  if (complete == null) {
    when(
      () => completeOnboarding(any()),
    ).thenAnswer((_) async => const Right(OnboardingResult()));
  }
  final getSettings = _MockGetSettings();
  when(() => getSettings(any())).thenAnswer(
    (_) async => Right(onboardingSettings(monthlyIncome: storedIncome)),
  );
  final bloc = OnboardingBloc(
    completeOnboarding: completeOnboarding,
    getSettings: getSettings,
  );
  addTearDown(bloc.close);
  for (final event in events) {
    bloc.add(event);
  }
  await tester.binding.setSurfaceSize(const Size(400, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await pumpLocalized(
    tester,
    Scaffold(body: page),
    wrap: (app) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: bloc),
        BlocProvider<SettingsBloc>.value(
          value: mockBloc<MockSettingsBloc, SettingsState>(
            MockSettingsBloc(),
            SettingsLoaded(settings ?? onboardingSettings()),
          ),
        ),
      ],
      child: app,
    ),
  );
  await tester.pumpAndSettle();

  return bloc;
}

ElevatedButton primaryButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
