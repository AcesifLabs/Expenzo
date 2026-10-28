import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

typedef RecordBudgetLink = ({String id, String budgetId});

abstract class RecordRemoteDatasource {
  Future<void> fillMissingBudgetLinks(List<RecordBudgetLink> links);
}

class RecordRemoteDatasourceImpl implements RecordRemoteDatasource {
  final ApiClient apiClient;

  RecordRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<void> fillMissingBudgetLinks(List<RecordBudgetLink> links) async {
    try {
      await apiClient.dio.post<Object?>(
        ApiConstants.recordBudgetLinks,
        data: {
          'links': [
            for (final l in links) {'id': l.id, 'budgetId': l.budgetId},
          ],
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
