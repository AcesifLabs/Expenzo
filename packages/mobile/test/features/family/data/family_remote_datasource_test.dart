import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/family/data/datasources/family_remote_datasource.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/factories/family_factory.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

Response<Object?> _ok(String path, Object? data, [int status = 200]) =>
    Response(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: status,
    );

DioException _error(int status, [Object? data]) {
  final options = RequestOptions(path: '/groups');

  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: data),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  late _MockDio dio;
  late FamilyRemoteDatasourceImpl datasource;

  setUp(() {
    dio = _MockDio();
    final client = _MockApiClient();
    when(() => client.dio).thenReturn(dio);
    datasource = FamilyRemoteDatasourceImpl(apiClient: client);
  });

  test('getMyGroup reads GET /groups/me', () async {
    when(
      () => dio.get<Object?>('/groups/me'),
    ).thenAnswer((_) async => _ok('/groups/me', myGroupJson()));

    expect((await datasource.getMyGroup())?.group.id, 'group-1');
  });

  test('getMyGroup returns null when not in a group', () async {
    when(
      () => dio.get<Object?>('/groups/me'),
    ).thenAnswer((_) async => _ok('/groups/me', {'group': null, 'me': null}));

    expect(await datasource.getMyGroup(), isNull);
  });

  test('createGroup posts the body and leaves out a missing budget', () async {
    when(
      () => dio.post<Object?>('/groups', data: any(named: 'data')),
    ).thenAnswer((_) async => _ok('/groups', myGroupJson(), 201));

    await datasource.createGroup(name: 'Rahman Family', currencyCode: 'BDT');

    verify(
      () => dio.post<Object?>(
        '/groups',
        data: {'name': 'Rahman Family', 'currencyCode': 'BDT'},
      ),
    ).called(1);
  });

  test('createInvite posts to the group invites path', () async {
    when(() => dio.post<Object?>('/groups/group-1/invites')).thenAnswer(
      (_) async => _ok('/', {
        'code': 'RF4XK2',
        'expiresAt': '2026-03-03T10:00:00.000Z',
      }, 201),
    );

    expect((await datasource.createInvite('group-1')).code, 'RF4XK2');
  });

  test('joinGroup posts code and currency', () async {
    when(
      () => dio.post<Object?>('/groups/join', data: any(named: 'data')),
    ).thenAnswer((_) async => _ok('/', myGroupJson(role: 'member')));

    final group = await datasource.joinGroup(
      code: 'RF4XK2',
      currencyCode: 'BDT',
    );

    expect(group.myRole, GroupRole.member);
    verify(
      () => dio.post<Object?>(
        '/groups/join',
        data: {'code': 'RF4XK2', 'currencyCode': 'BDT'},
      ),
    ).called(1);
  });

  test('updateRole patches the member with the role', () async {
    when(
      () => dio.patch<Object?>(
        '/groups/group-1/members/user-2',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => _ok('/', myGroupJson()));

    await datasource.updateRole(
      groupId: 'group-1',
      userId: 'user-2',
      role: GroupRole.viewer,
    );

    verify(
      () => dio.patch<Object?>(
        '/groups/group-1/members/user-2',
        data: {'role': 'viewer'},
      ),
    ).called(1);
  });

  test('removeMember and deleteGroup send DELETE', () async {
    when(
      () => dio.delete<Object?>(any()),
    ).thenAnswer((_) async => _ok('/', null, 204));

    await datasource.removeMember(groupId: 'group-1', userId: 'user-2');
    await datasource.deleteGroup('group-1');

    verify(
      () => dio.delete<Object?>('/groups/group-1/members/user-2'),
    ).called(1);
    verify(() => dio.delete<Object?>('/groups/group-1')).called(1);
  });

  test('getSummary sends utcOffsetMinutes', () async {
    when(
      () => dio.get<Object?>(
        '/groups/group-1/summary',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => _ok('/', groupSummaryJson()));

    await datasource.getSummary('group-1', utcOffsetMinutes: 360);

    verify(
      () => dio.get<Object?>(
        '/groups/group-1/summary',
        queryParameters: {'utcOffsetMinutes': 360},
      ),
    ).called(1);
  });

  for (final (status, code) in [
    (409, 'CURRENCY_MISMATCH'),
    (409, 'GROUP_FULL'),
    (410, 'INVITE_EXPIRED'),
    (404, 'INVITE_NOT_FOUND'),
  ]) {
    test('a $status $code reaches the caller with code and status', () async {
      when(
        () => dio.post<Object?>('/groups/join', data: any(named: 'data')),
      ).thenThrow(_error(status, {'code': code, 'message': 'x'}));

      await expectLater(
        datasource.joinGroup(code: 'RF4XK2', currencyCode: 'USD'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', code)
              .having((e) => e.statusCode, 'statusCode', status),
        ),
      );
    });
  }

  test('a network error has no status', () async {
    when(() => dio.get<Object?>('/groups/me')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/groups/me'),
        type: DioExceptionType.connectionError,
      ),
    );

    await expectLater(
      datasource.getMyGroup(),
      throwsA(
        isA<ServerException>().having(
          (e) => e.statusCode,
          'statusCode',
          isNull,
        ),
      ),
    );
  });
}
