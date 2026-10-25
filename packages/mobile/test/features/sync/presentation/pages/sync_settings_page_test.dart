import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/sync/domain/entities/sync_overview.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_bloc.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_event.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_state.dart';
import 'package:expense_tracker/features/sync/presentation/pages/sync_settings_page.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/factories/user_settings_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockSyncScreenBloc extends Mock implements SyncScreenBloc {}

const _signedIn = Authenticated(User(uid: 'u1', displayName: 'Sam'));

SyncOverview _overview({int failures = 0, bool failed = false}) => SyncOverview(
  isSignedIn: true,
  lastSuccessfulSyncAt: failed ? null : DateTime(2026, 10, 15, 9),
  lastFailedSyncAt: failed ? DateTime(2026, 10, 15, 9) : null,
  consecutiveFailures: failures,
  pendingCount: 2,
);

void main() {
  late _MockSyncScreenBloc syncBloc;
  late MockSettingsBloc settingsBloc;

  Future<void> pump(
    WidgetTester tester, {
    AuthState auth = _signedIn,
    SyncOverview? overview,
    SyncScreenState? state,
    bool syncEnabled = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    syncBloc = mockBloc<_MockSyncScreenBloc, SyncScreenState>(
      _MockSyncScreenBloc(),
      state ??
          SyncScreenState(
            loadStatus: SyncScreenLoadStatus.loaded,
            overview: overview ?? _overview(),
          ),
    );
    settingsBloc = mockBloc<MockSettingsBloc, SettingsState>(
      MockSettingsBloc(),
      SettingsLoaded(makeUserSettings().copyWith(syncEnabled: syncEnabled)),
    );
    await pumpLocalized(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(
            value: mockBloc<MockAuthBloc, AuthState>(MockAuthBloc(), auth),
          ),
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<SyncScreenBloc>.value(value: syncBloc),
        ],
        child: const Scaffold(body: SyncSettingsView()),
      ),
    );
  }

  ElevatedButton syncNowButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Sync now'),
          matching: find.byWidgetPredicate((w) => w is ElevatedButton),
        ),
      );

  testWidgets('signed out shows only the sign-in card', (tester) async {
    await pump(tester, auth: const Unauthenticated());

    expect(find.text('Sync your data'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sync now'), findsNothing);
    expect(find.text('Sync on this device'), findsNothing);
  });

  testWidgets('signed in shows status, last sync, pending and the switch', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Sync is on'), findsOneWidget);
    expect(find.text('Last synced'), findsOneWidget);
    expect(find.text('2 changes waiting to send'), findsOneWidget);
    expect(find.text('Sync on this device'), findsOneWidget);
    expect(
      find.textContaining(RegExp('backup', caseSensitive: false)),
      findsNothing,
    );
  });

  testWidgets('a failed sync shows the failure row and Retry syncs', (
    tester,
  ) async {
    await pump(tester, overview: _overview(failed: true, failures: 1));

    expect(find.textContaining('Last sync failed'), findsOneWidget);
    await tester.tap(find.text('Retry'));

    verify(() => syncBloc.add(const SyncNowRequested())).called(1);
  });

  testWidgets('Failed Sync Changes show with their own Retry', (tester) async {
    await pump(
      tester,
      state: SyncScreenState(
        loadStatus: SyncScreenLoadStatus.loaded,
        overview: _overview(),
        failedCount: 3,
      ),
    );

    expect(find.text("3 changes couldn't sync"), findsOneWidget);
    await tester.tap(find.text('Retry'));

    verify(() => syncBloc.add(const FailedChangesRetryRequested())).called(1);
  });

  testWidgets('no failed row while nothing failed', (tester) async {
    await pump(tester);

    expect(find.textContaining("couldn't sync"), findsNothing);
  });

  testWidgets('Sync now adds SyncNowRequested', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Sync now'));

    verify(() => syncBloc.add(const SyncNowRequested())).called(1);
  });

  testWidgets('the banner shows from the third failure in a row', (
    tester,
  ) async {
    await pump(tester, overview: _overview(failed: true, failures: 2));
    expect(find.text("Sync isn't working right now"), findsNothing);

    await pump(tester, overview: _overview(failed: true, failures: 3));
    expect(find.text("Sync isn't working right now"), findsOneWidget);
  });

  testWidgets('off disables Sync now and says Sync is off', (tester) async {
    await pump(tester, syncEnabled: false);

    expect(find.text('Sync is off'), findsOneWidget);
    expect(syncNowButton(tester).onPressed, isNull);
  });

  testWidgets('the switch saves the new value', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(Switch));

    verify(
      () => settingsBloc.add(const UpdateSyncEnabled(enabled: false)),
    ).called(1);
  });

  testWidgets('a failed load offers Retry, which reloads', (tester) async {
    await pump(
      tester,
      state: const SyncScreenState(loadStatus: SyncScreenLoadStatus.error),
    );

    expect(find.text("Couldn't load sync status"), findsOneWidget);
    await tester.tap(find.text('Retry'));

    verify(() => syncBloc.add(const SyncScreenStarted())).called(1);
  });

  testWidgets('while loading a spinner shows', (tester) async {
    await pump(tester, state: const SyncScreenState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a failed last-sync row uses the warning colour', (tester) async {
    await pump(tester, overview: _overview(failed: true, failures: 1));

    final title = tester.widget<Text>(find.textContaining('Last sync failed'));
    final palette = tester
        .element(find.textContaining('Last sync failed'))
        .palette;

    expect(title.style?.color, palette.warning);
  });

  testWidgets('Sync now is as wide as the list content', (tester) async {
    await pump(tester);

    final listWidth = tester.getSize(find.byType(ListView)).width;
    final buttonWidth = tester.getSize(find.byType(ElevatedButton)).width;

    expect(buttonWidth, listWidth - AppSpacing.pagePadding.horizontal);
  });
}
