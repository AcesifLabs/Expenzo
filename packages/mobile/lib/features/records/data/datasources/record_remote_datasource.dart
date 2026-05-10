import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/record.dart' as entity;

abstract class RecordRemoteDatasource {
  Future<RecordRemoteResponse> getRecords({
    String? cursor,
    int? limit,
    String? startDate,
    String? endDate,
    List<String>? categoryIds,
    String? recordType,
  });
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

class RecordRemoteDatasourceImpl implements RecordRemoteDatasource {
  final ApiClient apiClient;

  RecordRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<RecordRemoteResponse> getRecords({
    String? cursor,
    int? limit,
    String? startDate,
    String? endDate,
    List<String>? categoryIds,
    String? recordType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryParams['categoryIds'] = categoryIds.join(',');
      }
      if (recordType != null) queryParams['recordType'] = recordType;

      final response = await apiClient.dio.get(
        ApiConstants.records,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final body = response.data as Map<String, dynamic>;
      final items = (body['data'] as List<dynamic>?) ?? [];

      final records = items.map((json) {
        final rt = json['recordType'] as String? ?? 'IN';
        return entity.Record(
          id: json['id'] as String?,
          amount: json['amount'] != null
              ? num.parse(json['amount'].toString()).toDouble()
              : 0.0,
          description: json['description'] as String? ?? '',
          date: DateTime.parse(json['date'] as String),
          categoryId: json['categoryId'] as String?,
          source: ExpenseSource.values.firstWhere(
            (s) => s.name == (json['source'] as String? ?? 'manual'),
            orElse: () => ExpenseSource.manual,
          ),
          sourceId: json['sourceId'] as String?,
          recordType: rt == 'IN' ? RecordType.income : RecordType.expense,
          createdAt: json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now().toUtc(),
          updatedAt: json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now().toUtc(),
        );
      }).toList();

      return RecordRemoteResponse(
        data: records,
        nextCursor: body['nextCursor'] as String?,
        total: body['total'] as int? ?? records.length,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
