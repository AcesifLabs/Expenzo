import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:expense_tracker/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';

@GenerateMocks([RecordDao, CategoryDao])
void main() {
  group('ReportsRepository', () {
    test('should fetch spending trend from DAO', () async {
      // TODO: Implement test with mocks
    });

    test('should fetch category breakdown from DAO', () async {
      // TODO: Implement test with mocks
    });
  });
}
