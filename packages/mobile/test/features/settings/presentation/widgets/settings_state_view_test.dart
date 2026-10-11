import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_state_view.dart';
import '../../../../support/factories/user_settings_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockSettingsBloc extends Mock implements SettingsBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late _MockSettingsBloc bloc;
  late StreamController<SettingsState> states;

  setUpAll(() => registerFallbackValue(_FakeSettingsEvent()));

  setUp(() {
    bloc = _MockSettingsBloc();
    states = StreamController<SettingsState>.broadcast();
    when(() => bloc.stream).thenAnswer((_) => states.stream);
    when(() => bloc.close()).thenAnswer((_) async {});
    when(() => bloc.add(any())).thenReturn(null);
  });

  tearDown(() => states.close());

  Future<void> pump(WidgetTester tester, SettingsState initial) {
    when(() => bloc.state).thenReturn(initial);

    return pumpLocalized(
      tester,
      Scaffold(
        body: SettingsStateView(
          builder: (_, settings) => Text('theme: ${settings.theme}'),
        ),
      ),
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
  }

  Future<void> emit(WidgetTester tester, SettingsState state) async {
    when(() => bloc.state).thenReturn(state);
    states.add(state);
    await tester.pump();
  }

  testWidgets('shows a spinner while settings first load', (tester) async {
    await pump(tester, const SettingsLoading());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a failed first load offers Try again, which reloads', (
    tester,
  ) async {
    await pump(tester, const SettingsError('Storage error'));

    expect(find.text("Couldn't load your settings."), findsOneWidget);
    await tester.tap(find.text('Try again'));
    verify(() => bloc.add(const LoadSettings())).called(1);
  });

  testWidgets('after the account is deleted it offers Try again instead '
      'of spinning', (tester) async {
    await pump(tester, const AccountDeleted());

    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('Try again'));
    verify(() => bloc.add(const LoadSettings())).called(1);
  });

  testWidgets('keeps the content on screen while a save runs', (tester) async {
    await pump(tester, SettingsLoaded(makeUserSettings(theme: 'dark')));
    await emit(tester, const SettingsLoading());

    expect(find.text('theme: dark'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a failed save shows a snackbar and keeps the content', (
    tester,
  ) async {
    await pump(tester, SettingsLoaded(makeUserSettings(theme: 'dark')));
    await emit(tester, const SettingsLoading());
    await emit(tester, const SettingsError('Storage error'));
    await tester.pump();

    expect(find.text('Storage error'), findsOneWidget);
    expect(find.text('theme: dark'), findsOneWidget);
  });
}
