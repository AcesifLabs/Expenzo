import 'dart:async';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/recurring/application/recurring_auto_poster.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_list_page.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';

import '../../../../support/factories/recurring_factory.dart';
import '../../../../support/factories/user_settings_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockRecurringBloc extends Mock implements RecurringBloc {}

class _MockSettingsBloc extends Mock implements SettingsBloc {}

class _MockAutoPoster extends Mock implements RecurringAutoPoster {}

class _FakeRecurringEvent extends Fake implements RecurringEvent {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late _MockRecurringBloc recurringBloc;
  late _MockSettingsBloc settingsBloc;
  late StreamController<RecurringState> recurringStates;
  late _MockAutoPoster autoPoster;

  final rent = makeRecurring(id: 'rent', description: 'Rent');

  setUpAll(() {
    registerFallbackValue(_FakeRecurringEvent());
    registerFallbackValue(_FakeSettingsEvent());
  });

  setUp(() {
    recurringBloc = _MockRecurringBloc();
    settingsBloc = _MockSettingsBloc();
    recurringStates = StreamController<RecurringState>.broadcast();
    when(() => recurringBloc.stream).thenAnswer((_) => recurringStates.stream);
    when(() => recurringBloc.close()).thenAnswer((_) async {});
    when(() => settingsBloc.state).thenReturn(
      SettingsLoaded(makeUserSettings(defaultRecurringFrequency: 'weekly')),
    );
    when(() => settingsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => settingsBloc.close()).thenAnswer((_) async {});
    autoPoster = _MockAutoPoster();
    when(() => autoPoster.isReadyToPost()).thenAnswer((_) async => true);
    di.getIt.registerSingleton<RecurringAutoPoster>(autoPoster);
  });

  tearDown(() async {
    await recurringStates.close();
    await di.getIt.unregister<RecurringAutoPoster>();
  });

  Future<void> emit(WidgetTester tester, RecurringState state) async {
    when(() => recurringBloc.state).thenReturn(state);
    recurringStates.add(state);
    // One frame delivers the state, the next shows its rebuild or snackbar.
    await tester.pump();
    await tester.pump();
  }

  Future<void> pumpPage(
    WidgetTester tester, [
    List<RecurringTransaction>? items,
  ]) async {
    when(
      () => recurringBloc.state,
    ).thenReturn(RecurringLoaded(items ?? [rent]));
    await pumpLocalized(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<RecurringBloc>.value(value: recurringBloc),
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
        ],
        child: const RecurringListView(),
      ),
    );
    await tester.pump();
  }

  Finder processButton() =>
      find.widgetWithIcon(IconButton, PiconsRegular.arrowsCounterClockwise);

  testWidgets('the three sections render in order', (tester) async {
    await pumpPage(tester);

    final frequency = tester.getTopLeft(find.text('DEFAULT FREQUENCY')).dy;
    final autoCreate = tester.getTopLeft(find.text('AUTO-CREATE')).dy;
    final active = tester.getTopLeft(find.text('ACTIVE RECURRING')).dy;
    expect(frequency, lessThan(autoCreate));
    expect(autoCreate, lessThan(active));
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('the stored default is checked; tapping Yearly saves it', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Weekly'),
        matching: find.byIcon(PiconsRegular.checkCircle),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Yearly'));

    verify(
      () => settingsBloc.add(const UpdateDefaultRecurringFrequency('yearly')),
    ).called(1);
  });

  testWidgets('turning Auto-create on saves it and posts due items', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    verify(
      () => settingsBloc.add(const UpdateRecurringAutoCreate(true)),
    ).called(1);
    verify(
      () => recurringBloc.add(const ProcessRecurring(automatic: true)),
    ).called(1);
  });

  testWidgets('before the first pull, turning Auto-create on only saves it', (
    tester,
  ) async {
    when(() => autoPoster.isReadyToPost()).thenAnswer((_) async => false);
    await pumpPage(tester);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    verify(
      () => settingsBloc.add(const UpdateRecurringAutoCreate(true)),
    ).called(1);
    verifyNever(() => recurringBloc.add(any(that: isA<ProcessRecurring>())));
  });

  testWidgets('turning Auto-create off only saves it', (tester) async {
    when(
      () => settingsBloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings(recurringAutoCreate: true)));
    await pumpPage(tester);

    await tester.tap(find.byType(Switch).first);

    verify(
      () => settingsBloc.add(const UpdateRecurringAutoCreate(false)),
    ).called(1);
    verifyNever(() => recurringBloc.add(any(that: isA<ProcessRecurring>())));
  });

  testWidgets('an empty list shows the empty text and no ACTIVE header', (
    tester,
  ) async {
    await pumpPage(tester, []);

    expect(find.text('DEFAULT FREQUENCY'), findsOneWidget);
    expect(find.text('No recurring transactions'), findsOneWidget);
    expect(find.text('ACTIVE RECURRING'), findsNothing);
  });

  testWidgets('while processing the list stays and the button is disabled', (
    tester,
  ) async {
    await pumpPage(tester);

    await emit(tester, const RecurringLoading());

    expect(find.text('Rent'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<IconButton>(processButton()).onPressed, isNull);
    final rowSwitch = tester.widget<Switch>(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Rent'),
        matching: find.byType(Switch),
      ),
    );
    expect(rowSwitch.onChanged, isNull);
  });

  testWidgets('a manual run with nothing due says so', (tester) async {
    await pumpPage(tester);

    await emit(tester, const RecurringProcessed(0));

    expect(find.text('No transactions due'), findsOneWidget);
  });

  testWidgets('an automatic run with nothing due stays silent', (tester) async {
    await pumpPage(tester);

    await emit(tester, const RecurringProcessed(0, automatic: true));

    expect(find.text('No transactions due'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('posted items are counted', (tester) async {
    await pumpPage(tester);

    await emit(tester, const RecurringProcessed(2));

    expect(find.text('2 transactions added'), findsOneWidget);
  });
}
