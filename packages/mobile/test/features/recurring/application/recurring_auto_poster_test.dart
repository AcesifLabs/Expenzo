import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/recurring/application/recurring_auto_poster.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/post_due_recurring.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

import '../../../support/factories/user_settings_factory.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockPostDueRecurring extends Mock implements PostDueRecurring {}

void main() {
  late _MockGetSettings getSettings;
  late _MockPostDueRecurring postDueRecurring;
  late int afterPostCalls;
  late bool signedIn;
  late RecurringAutoPoster poster;

  setUpAll(() {
    // The poster logs the failures these tests provoke.
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getSettings = _MockGetSettings();
    postDueRecurring = _MockPostDueRecurring();
    afterPostCalls = 0;
    signedIn = false;
    poster = RecurringAutoPoster(
      getSettings: getSettings,
      postDueRecurring: postDueRecurring,
      isSignedIn: () async => signedIn,
      afterPost: () async => afterPostCalls++,
    );
  });

  void autoCreate({required bool on}) {
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(makeUserSettings(recurringAutoCreate: on)));
  }

  void posts(int created) {
    when(
      () => postDueRecurring(automatic: any(named: 'automatic')),
    ).thenAnswer((_) async => Right(created));
  }

  void verifyNoPost() =>
      verifyNever(() => postDueRecurring(automatic: any(named: 'automatic')));

  test('auto-create off posts nothing', () async {
    autoCreate(on: false);

    await poster.runIfEnabled();

    verifyNoPost();
  });

  test('auto-create on posts once, as an automatic run', () async {
    autoCreate(on: true);
    posts(0);

    await poster.runIfEnabled();

    verify(() => postDueRecurring(automatic: true)).called(1);
  });

  test('a settings failure posts nothing and does not throw', () async {
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'prefs')));

    await poster.runIfEnabled();

    verifyNoPost();
  });

  test('posted Records run afterPost once', () async {
    autoCreate(on: true);
    posts(2);

    await poster.runIfEnabled();

    expect(afterPostCalls, 1);
  });

  test('nothing posted skips afterPost', () async {
    autoCreate(on: true);
    posts(0);

    await poster.runIfEnabled();

    expect(afterPostCalls, 0);
  });

  test('a posting failure skips afterPost and does not throw', () async {
    autoCreate(on: true);
    when(
      () => postDueRecurring(automatic: any(named: 'automatic')),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));

    await poster.runIfEnabled();

    expect(afterPostCalls, 0);
  });

  test('a throwing post does not throw', () async {
    autoCreate(on: true);
    when(
      () => postDueRecurring(automatic: any(named: 'automatic')),
    ).thenThrow(StateError('boom'));

    await expectLater(poster.runIfEnabled(), completes);
  });

  test('signed in, nothing posts before the first pull', () async {
    autoCreate(on: true);
    posts(1);
    signedIn = true;

    await poster.runWhenReady();

    verifyNoPost();
  });

  test('signed out, opening or resuming the app posts', () async {
    autoCreate(on: true);
    posts(1);

    await poster.runWhenReady();

    verify(() => postDueRecurring(automatic: true)).called(1);
  });

  test('a failing sign-in check posts nothing and does not throw', () async {
    autoCreate(on: true);
    posts(1);
    poster = RecurringAutoPoster(
      getSettings: getSettings,
      postDueRecurring: postDueRecurring,
      isSignedIn: () async => throw StateError('keystore'),
    );

    await expectLater(poster.runWhenReady(), completes);

    verifyNoPost();
  });

  test('only the first successful pull of the session posts', () async {
    autoCreate(on: true);
    posts(1);

    await poster.runAfterSync(pulled: true);
    await poster.runAfterSync(pulled: true);

    verify(() => postDueRecurring(automatic: true)).called(1);
  });

  test('a failed pull posts nothing and waits for a good one', () async {
    autoCreate(on: true);
    posts(1);
    signedIn = true;

    await poster.runAfterSync(pulled: false);
    verifyNoPost();
    expect(await poster.isReadyToPost(), isFalse);

    await poster.runAfterSync(pulled: true);
    verify(() => postDueRecurring(automatic: true)).called(1);
  });

  test('signed in, resuming after the first pull posts', () async {
    autoCreate(on: true);
    posts(0);
    signedIn = true;
    await poster.runAfterSync(pulled: true);

    await poster.runWhenReady();

    verify(() => postDueRecurring(automatic: true)).called(2);
  });

  test('after sign-out the next account must pull again', () async {
    autoCreate(on: true);
    posts(0);
    signedIn = true;
    await poster.runAfterSync(pulled: true);

    poster.resetSession();
    await poster.runWhenReady();
    expect(await poster.isReadyToPost(), isFalse);

    await poster.runAfterSync(pulled: true);
    verify(() => postDueRecurring(automatic: true)).called(2);
  });
}
