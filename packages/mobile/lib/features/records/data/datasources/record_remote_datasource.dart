import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/record.dart' as entity;

abstract class RecordRemoteDatasource {
  /// Throws: [ServerException] if the API request fails.
  Future<RecordRemoteResponse> getRecords(RemoteRecordQuery query);
}

class RecordRemoteResponse {
  final List<entity.Record> data;
  final String? nextCursor;
  final int total;

  const RecordRemoteResponse({
    required this.data,
    this.nextCursor,
    this.total = 0,
  });
}

class RemoteRecordQuery {
  final String? cursor;
  final int? limit;
  final String? startDate;
  final String? endDate;
  final List<String>? categoryIds;
  final String? recordType;

  const RemoteRecordQuery({
    this.cursor,
    this.limit,
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.recordType,
  });
}

class RecordRemoteDatasourceImpl implements RecordRemoteDatasource {
  final ApiClient apiClient;

  RecordRemoteDatasourceImpl({required this.apiClient});

  /// Throws: [ServerException] if the API request fails.
  @override
  Future<RecordRemoteResponse> getRecords(RemoteRecordQuery query) async {
    try {
      final queryParams = _buildQueryParams(query);

      final response = await apiClient.dio.get(
        ApiConstants.records,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic>) {
        throw ServerException(
          message: 'Unexpected server response shape: ${rawData.runtimeType}',
        );
      }
      final body = rawData;
      final items = (body['data'] as List<dynamic>?) ?? [];
      final records = items
          .map((json) => _parseRecord(json as Map<String, dynamic>))
          .toList();

      return RecordRemoteResponse(
        data: records,
        nextCursor: body['nextCursor'] as String?,
        total: body['total'] as int? ?? records.length,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _buildQueryParams(RemoteRecordQuery query) {
    final params = <String, dynamic>{};
    if (query.cursor != null) params['cursor'] = query.cursor;
    if (query.limit != null) params['limit'] = query.limit.toString();
    if (query.startDate != null) params['startDate'] = query.startDate;
    if (query.endDate != null) params['endDate'] = query.endDate;
    final catIds = query.categoryIds;
    if (catIds != null && catIds.isNotEmpty) {
      params['categoryIds'] = catIds.join(',');
    }
    if (query.recordType != null) params['recordType'] = query.recordType;

    return params;
  }

  entity.Record _parseRecord(Map<String, dynamic> json) {
    final rt = json['recordType'] as String? ?? RecordType.income.dbValue;
    final now = DateTime.now().toUtc();

    return entity.Record(
      id: json['id'] as String?,
      amount: json['amount'] != null
          ? num.parse(json['amount'].toString()).toDouble()
          : 0.0,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String?,
      budgetId: json['budgetId'] as String?,
      source: ExpenseSource.values.firstWhere(
        (s) =>
            s.name == (json['source'] as String? ?? ExpenseSource.manual.name),
        orElse: () => ExpenseSource.manual,
      ),
      sourceId: json['sourceId'] as String?,
      recordType: rt == RecordType.income.dbValue
          ? RecordType.income
          : RecordType.expense,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : now,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : now,
    );
  }
}
