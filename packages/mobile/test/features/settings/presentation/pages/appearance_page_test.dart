import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/appearance_page.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/theme_preview_card.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../../support/factories/user_settings_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockSettingsBloc extends Mock implements SettingsBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late _MockSettingsBloc bloc;

  setUpAll(() => registerFallbackValue(_FakeSettingsEvent()));

  setUp(() {
    bloc = _MockSettingsBloc();
    when(
      () => bloc.stream,
    ).thenAnswer((_) => const Stream<SettingsState>.empty());
    when(() => bloc.close()).thenAnswer((_) async {});
    when(() => bloc.add(any())).thenReturn(null);
  });

  Future<void> pump(WidgetTester tester, {required String theme}) {
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings(theme: theme)));

    return pumpLocalized(
      tester,
      const Scaffold(body: AppearanceView()),
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
  }

  testWidgets('the stored theme row has the check mark', (tester) async {
    await pump(tester, theme: 'dark');

    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Dark'),
        matching: find.byIcon(PiconsRegular.checkCircle),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);
  });

  testWidgets('tapping Match device saves the system theme', (tester) async {
    await pump(tester, theme: 'dark');

    await tester.tap(find.text('Match device'));
    verify(() => bloc.add(const UpdateTheme('system'))).called(1);
  });

  testWidgets('with Light stored the preview shows light mode', (tester) async {
    await pump(tester, theme: 'light');

    expect(find.text('Light mode preview'), findsOneWidget);
  });

  testWidgets('with Dark stored the preview shows dark mode', (tester) async {
    await pump(tester, theme: 'dark');

    expect(find.text('Dark mode preview'), findsOneWidget);
  });

  testWidgets('does not overflow at the 2.0x text scale cap in Bangla', (
    tester,
  ) async {
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings(theme: 'dark')));
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: const Scaffold(body: AppearanceView()),
        ),
      ),
      locale: AppLocale.bn,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
    await tester.scrollUntilVisible(find.byType(ThemePreviewCard), 200);

    expect(tester.takeException(), isNull);
  });
}
