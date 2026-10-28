import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/delete_account_dialog.dart';
import 'package:expense_tracker/features/settings/presentation/pages/profile_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../../support/pump_localized.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

class _MockDeleteAccountBloc extends Mock implements DeleteAccountBloc {}

void main() {
  late _MockAuthBloc authBloc;
  late _MockDeleteAccountBloc deleteBloc;

  const user = User(
    uid: 'u1',
    email: 'sam@example.com',
    displayName: 'Sam Rahman',
  );

  setUpAll(() => registerFallbackValue(const DeleteAccountRequested()));

  setUp(() {
    authBloc = _MockAuthBloc();
    deleteBloc = _MockDeleteAccountBloc();
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => authBloc.close()).thenAnswer((_) async {});
    when(
      () => deleteBloc.stream,
    ).thenAnswer((_) => const Stream<DeleteAccountState>.empty());
    when(() => deleteBloc.close()).thenAnswer((_) async {});
    when(() => deleteBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpProfile(
    WidgetTester tester, {
    required AuthState authState,
    DeleteAccountState deleteState = const DeleteAccountState(),
  }) {
    when(() => authBloc.state).thenReturn(authState);
    when(() => deleteBloc.state).thenReturn(deleteState);

    return pumpLocalized(
      tester,
      const Scaffold(body: ProfileView()),
      wrap: (app) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<DeleteAccountBloc>.value(value: deleteBloc),
        ],
        child: app,
      ),
    );
  }

  Future<void> tapDeleteAccount(WidgetTester tester) async {
    final row = find.text(t.settings.deleteAccount);
    await tester.scrollUntilVisible(row, 100);
    await tester.tap(row, warnIfMissed: false);

    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('signed in shows the name and email', (tester) async {
    await pumpProfile(tester, authState: const Authenticated(user));

    expect(find.text('Sam Rahman'), findsWidgets);
    expect(find.text('sam@example.com'), findsWidgets);
    expect(find.text(t.settings.profile.signedInWith), findsOneWidget);
  });

  testWidgets('confirming the dialog adds DeleteAccountRequested', (
    tester,
  ) async {
    await pumpProfile(tester, authState: const Authenticated(user));

    await tapDeleteAccount(tester);
    expect(find.byType(DeleteAccountDialog), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text(t.common.delete));
    await tester.pumpAndSettle();

    verify(() => deleteBloc.add(const DeleteAccountRequested())).called(1);
  });

  testWidgets('while deleting, Delete account does not open the dialog', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      authState: const Authenticated(user),
      deleteState: const DeleteAccountState(
        status: DeleteAccountStatus.deleting,
      ),
    );

    expect(find.text(t.settings.profile.deletingAccount), findsOneWidget);
    await tapDeleteAccount(tester);

    expect(find.byType(DeleteAccountDialog), findsNothing);
  });

  testWidgets('signed out shows the Sign in button', (tester) async {
    await pumpProfile(tester, authState: const Unauthenticated());

    expect(find.text(t.settings.profile.signedOutTitle), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, t.settings.signIn.title),
      findsOneWidget,
    );
    expect(find.text(t.settings.deleteAccount), findsNothing);
  });
}
