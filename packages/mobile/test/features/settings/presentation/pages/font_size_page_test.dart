import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/font_size_page.dart';
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

  Future<void> pump(
    WidgetTester tester, {
    UserSettings? settings,
    AppLocale locale = AppLocale.en,
  }) {
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(settings ?? makeUserSettings()));

    return pumpLocalized(
      tester,
      const Scaffold(body: FontSizeView()),
      locale: locale,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
  }

  testWidgets('shows four sizes with the stored one selected', (tester) async {
    await pump(tester, settings: makeUserSettings(fontSize: AppFontSize.large));

    for (final label in ['Small', 'Medium', 'Large', 'Extra large']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Large'),
        matching: find.byIcon(PiconsRegular.checkCircle),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);
  });

  testWidgets('shows the sample transaction and no font family section', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Sample transaction'), findsOneWidget);
    expect(find.text('PREVIEW'), findsOneWidget);
    expect(find.textContaining('FONT FAMILY'), findsNothing);
  });

  testWidgets('tapping Large saves the large size', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Large'));
    verify(() => bloc.add(const UpdateFontSize(AppFontSize.large))).called(1);
  });

  testWidgets('renders in Bangla without overflow at the 2.0x text scale', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(SettingsLoaded(makeUserSettings()));
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: const Scaffold(body: FontSizeView()),
        ),
      ),
      locale: AppLocale.bn,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );

    expect(find.text('লেখার আকার'), findsWidgets);
    await tester.scrollUntilVisible(find.text('অনেক বড়'), 200);
    expect(tester.takeException(), isNull);
  });
}
