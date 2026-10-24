import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/family/data/datasources/family_local_datasource.dart';
import 'package:expense_tracker/features/family/data/datasources/family_remote_datasource.dart';
import 'package:expense_tracker/features/family/data/repositories/family_repository_impl.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/factories/family_factory.dart';

class _MockRemote extends Mock implements FamilyRemoteDatasource {}

void main() {
  late _MockRemote remote;
  late FamilyLocalDatasource local;
  late FamilyRepositoryImpl repository;
  late List<(MyGroup?, MyGroup?)> hookCalls;
  final now = DateTime.utc(2026, 4, 15, 12);
  final earlier = DateTime.utc(2026, 4, 14, 9);
  const offline = ServerException(message: 'connectionError');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    remote = _MockRemote();
    local = FamilyLocalDatasource(
      prefs: await SharedPreferences.getInstance(),
      currentUserId: () => 'uid-a',
    );
    hookCalls = [];
    repository = FamilyRepositoryImpl(
      remote: remote,
      local: local,
      clock: () => now,
      onGroupFetched: ({previous, current}) async =>
          hookCalls.add((previous, current)),
    );
  });

  group('getMyGroup', () {
    test('caches a fresh group with the fetch time', () async {
      when(() => remote.getMyGroup()).thenAnswer((_) async => makeMyGroup());

      final result = await repository.getMyGroup();

      final cached = result.getOrElse(() => throw StateError('left'));
      expect(cached.value, makeMyGroup());
      expect(cached.fromCache, isFalse);
      expect(local.readGroup()?.fetchedAt, now);
    });

    test('offline returns the cache with its original fetch time', () async {
      await local.writeGroup(makeMyGroup(), earlier);
      when(() => remote.getMyGroup()).thenThrow(offline);

      final cached = (await repository.getMyGroup()).getOrElse(
        () => throw StateError('left'),
      );

      expect(cached.fromCache, isTrue);
      expect(cached.fetchedAt, earlier);
    });

    test('offline without a cache is a NetworkFailure', () async {
      when(() => remote.getMyGroup()).thenThrow(offline);

      expect(
        (await repository.getMyGroup()).fold((f) => f, (_) => null),
        isA<NetworkFailure>(),
      );
    });

    test('a 5xx falls back to the cache, a 4xx does not', () async {
      await local.writeGroup(makeMyGroup(), earlier);
      when(
        () => remote.getMyGroup(),
      ).thenThrow(const ServerException(message: 'x', statusCode: 503));
      expect((await repository.getMyGroup()).isRight(), isTrue);

      when(
        () => remote.getMyGroup(),
      ).thenThrow(const ServerException(message: 'x', statusCode: 400));
      expect((await repository.getMyGroup()).isLeft(), isTrue);
    });

    test('preferCache returns the cache without a request', () async {
      await local.writeGroup(makeMyGroup(), earlier);

      await repository.getMyGroup(preferCache: true);

      verifyNever(() => remote.getMyGroup());
    });

    test('calls the hook with the previous and current group', () async {
      await local.writeGroup(makeMyGroup(), earlier);
      when(() => remote.getMyGroup()).thenAnswer((_) async => null);

      await repository.getMyGroup();

      expect(hookCalls, [(makeMyGroup(), null)]);
    });

    test('a 401 maps to AuthFailure', () async {
      when(
        () => remote.getMyGroup(),
      ).thenThrow(const ServerException(message: 'x', statusCode: 401));

      expect(
        (await repository.getMyGroup()).fold((f) => f, (_) => null),
        isA<AuthFailure>(),
      );
    });
  });

  group('getSummary', () {
    test(
      'offline with a cached group and summary returns the summary',
      () async {
        await local.writeGroup(makeMyGroup(), earlier);
        await local.writeSummary(makeGroupSummary(), earlier);
        when(
          () => remote.getSummary(
            any(),
            utcOffsetMinutes: any(named: 'utcOffsetMinutes'),
          ),
        ).thenThrow(offline);

        final cached = (await repository.getSummary(
          'group-1',
        )).getOrElse(() => throw StateError('left'));

        expect(cached.fromCache, isTrue);
        expect(cached.value, makeGroupSummary());
      },
    );

    test('drops a cached summary that has no cached group', () async {
      await local.writeSummary(makeGroupSummary(), earlier);
      when(
        () => remote.getSummary(
          any(),
          utcOffsetMinutes: any(named: 'utcOffsetMinutes'),
        ),
      ).thenThrow(offline);

      expect((await repository.getSummary('group-1')).isLeft(), isTrue);
      expect(local.readSummary(), isNull);
    });

    test('sends the device time zone offset', () async {
      when(
        () => remote.getSummary(
          any(),
          utcOffsetMinutes: any(named: 'utcOffsetMinutes'),
        ),
      ).thenAnswer((_) async => makeGroupSummary());

      await repository.getSummary('group-1');

      verify(
        () => remote.getSummary(
          'group-1',
          utcOffsetMinutes: now.timeZoneOffset.inMinutes,
        ),
      ).called(1);
    });

    test('NOT_IN_GROUP clears the cached group and summary', () async {
      await local.writeGroup(makeMyGroup(), earlier);
      await local.writeSummary(makeGroupSummary(), earlier);
      when(
        () => remote.getSummary(
          any(),
          utcOffsetMinutes: any(named: 'utcOffsetMinutes'),
        ),
      ).thenThrow(
        const ServerException(
          message: FailureCodes.notInGroup,
          statusCode: 404,
        ),
      );

      final failure = (await repository.getSummary(
        'group-1',
      )).fold((f) => f, (_) => null);

      expect(failure?.errorCode, FailureCodes.notInGroup);
      expect(repository.cachedGroup, isNull);
      expect(local.readSummary(), isNull);
    });
  });

  group('changes', () {
    test('join writes the returned group to the cache', () async {
      when(
        () => remote.joinGroup(code: 'RF4XK2', currencyCode: 'BDT'),
      ).thenAnswer((_) async => makeMyGroup(myRole: GroupRole.member));

      await repository.joinGroup(code: 'RF4XK2', currencyCode: 'BDT');

      expect(repository.cachedGroup?.myRole, GroupRole.member);
    });

    test('a CURRENCY_MISMATCH reaches the caller with its code', () async {
      when(
        () => remote.joinGroup(
          code: any(named: 'code'),
          currencyCode: any(named: 'currencyCode'),
        ),
      ).thenThrow(
        const ServerException(
          message: FailureCodes.currencyMismatch,
          statusCode: 409,
        ),
      );

      final failure = (await repository.joinGroup(
        code: 'RF4XK2',
        currencyCode: 'USD',
      )).fold((f) => f, (_) => null);

      expect(failure, isA<ServerFailure>());
      expect(failure?.errorCode, FailureCodes.currencyMismatch);
    });

    test('createInvite keeps the invite in the cached group', () async {
      await local.writeGroup(makeMyGroup(), earlier);
      final invite = InviteCode(
        code: 'NEW234',
        expiresAt: DateTime.utc(2026, 4, 17),
      );
      when(
        () => remote.createInvite('group-1'),
      ).thenAnswer((_) async => invite);

      await repository.createInvite('group-1');

      final cached = (await repository.getMyGroup(
        preferCache: true,
      )).getOrElse(() => throw StateError('left'));
      expect(cached.value?.invite, invite);
    });

    test('leave clears the cached group and summary', () async {
      await local.writeGroup(makeMyGroup(), earlier);
      await local.writeSummary(makeGroupSummary(), earlier);
      when(
        () => remote.removeMember(groupId: 'group-1', userId: 'user-1'),
      ).thenAnswer((_) async {});

      await repository.leaveGroup('group-1');

      expect(repository.cachedGroup, isNull);
      expect(repository.cachedSummary, isNull);
      expect(hookCalls.last, (makeMyGroup(), null));
    });

    test('cachedSummary returns the last written summary', () async {
      await local.writeGroup(makeMyGroup(), earlier);
      await local.writeSummary(makeGroupSummary(), earlier);

      expect(repository.cachedSummary, makeGroupSummary());
    });
  });
}
