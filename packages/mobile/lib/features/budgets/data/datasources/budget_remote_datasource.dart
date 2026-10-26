import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

typedef BudgetNameEntry = ({String id, String name});

abstract class BudgetRemoteDatasource {
  Future<void> fillMissingNames(List<BudgetNameEntry> names);
}

class BudgetRemoteDatasourceImpl implements BudgetRemoteDatasource {
  final ApiClient apiClient;

  BudgetRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<void> fillMissingNames(List<BudgetNameEntry> names) async {
    try {
      await apiClient.dio.post<Object?>(
        ApiConstants.budgetNames,
        data: {
          'names': [
            for (final n in names) {'id': n.id, 'name': n.name},
          ],
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
