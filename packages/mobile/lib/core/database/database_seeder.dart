import 'package:drift/drift.dart';
import '../constants/record_type.dart';
import 'app_database.dart';

class DatabaseSeeder {
  static const _incomeCategories = [
    ('default_in_salary', 'Salary', 'briefcase', '#43A047'),
    ('default_in_freelance', 'Freelance', 'laptop', '#00ACC1'),
    ('default_in_investment', 'Investment', 'chartLineUp', '#7CB342'),
    ('default_in_refund', 'Refund', 'arrowULeftDown', '#FF9800'),
    ('default_in_gift', 'Gift', 'gift', '#FFB300'),
    ('default_in_general', 'General', 'package', '#1E88E5'),
  ];

  static const _expenseCategories = [
    ('default_out_food', 'Food', 'forkKnife', '#FF9800'),
    ('default_out_shopping', 'Shopping', 'shoppingCart', '#D81B60'),
    ('default_out_transport', 'Transport', 'car', '#00ACC1'),
    ('default_out_home', 'Home', 'house', '#5E35B1'),
    ('default_out_health', 'Health', 'heartbeat', '#E53935'),
    ('default_out_entertainment', 'Entertainment', 'gameController', '#43A047'),
    ('default_out_bills', 'Bills', 'deviceMobile', '#FDD835'),
    ('default_out_travel', 'Travel', 'airplane', '#3949AB'),
    ('default_out_education', 'Education', 'graduationCap', '#00897B'),
    ('default_out_investment', 'Investment', 'currencyDollar', '#7CB342'),
    ('default_out_gifts', 'Gifts', 'gift', '#FFB300'),
    ('default_out_general', 'General', 'package', '#1E88E5'),
  ];

  static Future<void> seedInitialCategories(AppDatabase db) async {
    final existingCategories = await db.select(db.categories).get();
    if (existingCategories.isNotEmpty) {
      await _ensureIncomeCategoriesExist(db);

      return;
    }

    final now = DateTime.now();

    await db.batch((batch) {
      for (final cat in _expenseCategories) {
        batch.insert(
          db.categories,
          _buildCategoryCompanion(cat, RecordType.expense.dbValue, now),
        );
      }
      for (final cat in _incomeCategories) {
        batch.insert(
          db.categories,
          _buildCategoryCompanion(cat, RecordType.income.dbValue, now),
        );
      }
    });
  }

  static CategoriesCompanion _buildCategoryCompanion(
    (String, String, String, String) cat,
    String categoryType,
    DateTime now,
  ) {
    return CategoriesCompanion.insert(
      id: cat.$1,
      name: cat.$2,
      emoji: Value(cat.$3),
      color: Value(cat.$4),
      categoryType: Value(categoryType),
      isDefault: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  static Future<void> _ensureIncomeCategoriesExist(AppDatabase db) async {
    final existingIn = await (db.select(
      db.categories,
    )..where((t) => t.categoryType.equals('IN'))).get();
    final existingIds = existingIn.map((c) => c.id).toSet();

    final missing = _incomeCategories
        .where((cat) => !existingIds.contains(cat.$1))
        .toList();

    if (missing.isEmpty) return;

    final now = DateTime.now();

    await db.batch((batch) {
      for (final cat in missing) {
        batch.insert(
          db.categories,
          _buildCategoryCompanion(cat, RecordType.income.dbValue, now),
        );
      }
    });
  }
}
