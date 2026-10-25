import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

import '../../domain/entities/group_role.dart';
import '../../domain/entities/group_summary.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/entities/my_group.dart';
import '../models/family_json.dart';

/// The `/groups` endpoints (packages/backend/src/groups).
///
/// Every method throws [ServerException] on failure, with the HTTP status in
/// `statusCode` (null when the server was not reached) and the server's
/// error `code` (`FailureCodes`) as `message` when it sent one.
abstract class FamilyRemoteDatasource {
  /// Null when the caller is in no group.
  Future<MyGroup?> getMyGroup();

  Future<MyGroup> createGroup({
    required String name,
    required String currencyCode,
    double? monthlyBudget,
  });

  Future<InviteCode> createInvite(String groupId);

  Future<MyGroup> joinGroup({
    required String code,
    required String currencyCode,
  });

  Future<MyGroup> updateRole({
    required String groupId,
    required String userId,
    required GroupRole role,
  });

  /// Leaving is removing yourself.
  Future<void> removeMember({required String groupId, required String userId});

  Future<void> deleteGroup(String groupId);

  Future<GroupSummary> getSummary(
    String groupId, {
    required int utcOffsetMinutes,
  });
}

class FamilyRemoteDatasourceImpl implements FamilyRemoteDatasource {
  final ApiClient apiClient;

  Dio get _dio => apiClient.dio;

  FamilyRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<MyGroup?> getMyGroup() => _call(
    () async =>
        myGroupFromJson(_body(await _dio.get<Object?>(ApiConstants.groupsMe))),
  );

  @override
  Future<MyGroup> createGroup({
    required String name,
    required String currencyCode,
    double? monthlyBudget,
  }) => _call(() async {
    final response = await _dio.post<Object?>(
      ApiConstants.groups,
      data: {
        'name': name,
        'currencyCode': currencyCode,
        'monthlyBudget': ?monthlyBudget,
      },
    );

    return _requireGroup(response);
  });

  @override
  Future<InviteCode> createInvite(String groupId) => _call(
    () async => inviteFromJson(
      _body(await _dio.post<Object?>(ApiConstants.groupInvites(groupId))),
    ),
  );

  @override
  Future<MyGroup> joinGroup({
    required String code,
    required String currencyCode,
  }) => _call(() async {
    final response = await _dio.post<Object?>(
      ApiConstants.groupsJoin,
      data: {'code': code, 'currencyCode': currencyCode},
    );

    return _requireGroup(response);
  });

  @override
  Future<MyGroup> updateRole({
    required String groupId,
    required String userId,
    required GroupRole role,
  }) => _call(() async {
    final response = await _dio.patch<Object?>(
      ApiConstants.groupMember(groupId, userId),
      data: {'role': role.apiValue},
    );

    return _requireGroup(response);
  });

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) => _call(
    () => _dio.delete<Object?>(ApiConstants.groupMember(groupId, userId)),
  );

  @override
  Future<void> deleteGroup(String groupId) =>
      _call(() => _dio.delete<Object?>(ApiConstants.group(groupId)));

  @override
  Future<GroupSummary> getSummary(
    String groupId, {
    required int utcOffsetMinutes,
  }) => _call(() async {
    final response = await _dio.get<Object?>(
      ApiConstants.groupSummary(groupId),
      queryParameters: {'utcOffsetMinutes': utcOffsetMinutes},
    );

    return groupSummaryFromJson(_body(response));
  });

  MyGroup _requireGroup(Response<Object?> response) {
    final group = myGroupFromJson(_body(response));
    if (group == null) {
      throw const ServerException(message: 'Response had no group');
    }

    return group;
  }

  Json _body(Response<Object?> response) {
    final data = response.data;
    if (data is! Json) {
      // Not JSON: most likely a captive portal's page, not our server. No
      // status, so it reads as offline and the cache stays usable.
      throw ServerException(
        message: 'Unexpected response shape: ${data.runtimeType}',
      );
    }

    return data;
  }

  /// Unlike other remote datasources this keeps the status and the server
  /// error `code`: the repository needs both to pick the right failure.
  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Json ? data['code'] : null;
      throw ServerException(
        message: code is String ? code : e.message ?? e.type.name,
        statusCode: e.response?.statusCode,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      // The server answered, but not in a shape we can read: its fault, so
      // 502, which shows a server error and keeps the cache usable.
      throw ServerException(message: e.toString(), statusCode: 502);
    }
  }
}
