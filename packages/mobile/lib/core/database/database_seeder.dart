import 'package:drift/drift.dart';
import '../constants/record_type.dart';
import '../theme/category_palette.dart';
import 'app_database.dart';

class DatabaseSeeder {
  static const _incomeCategories = [
    ('default_in_salary', 'Salary', 'currencyDollar'),
    ('default_in_freelance', 'Freelance', 'briefcase'),
    ('default_in_investment', 'Investment', 'trendUp'),
    ('default_in_refund', 'Refund', 'arrowULeftDown'),
    ('default_in_gift', 'Gift', 'gift'),
    ('default_in_general', 'General', 'tag'),
  ];

  static const _expenseCategories = [
    ('default_out_food', 'Food & Dining', 'forkKnife'),
    ('default_out_shopping', 'Shopping', 'bag'),
    ('default_out_transport', 'Transport', 'car'),
    ('default_out_home', 'Home', 'house'),
    ('default_out_health', 'Health', 'heartbeat'),
    ('default_out_entertainment', 'Entertainment', 'ticket'),
    ('default_out_bills', 'Bills & Utilities', 'lightning'),
    ('default_out_travel', 'Travel', 'airplane'),
    ('default_out_education', 'Education', 'bookOpen'),
    ('default_out_investment', 'Investment', 'currencyDollar'),
    ('default_out_gifts', 'Gifts', 'gift'),
    ('default_out_general', 'General', 'tag'),
  ];

  /// Seeded English name per default category id. A default category whose
  /// stored name still matches is shown translated (`categoryDisplayName`).
  static final Map<String, String> seedNames = {
    for (final (id, name, _) in [..._incomeCategories, ..._expenseCategories])
      id: name,
  };

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
          mode: InsertMode.insertOrReplace,
        );
      }
      for (final cat in _incomeCategories) {
        batch.insert(
          db.categories,
          _buildCategoryCompanion(cat, RecordType.income.dbValue, now),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  static CategoriesCompanion _buildCategoryCompanion(
    (String, String, String) cat,
    String categoryType,
    DateTime now,
  ) {
    return CategoriesCompanion.insert(
      id: cat.$1,
      name: cat.$2,
      emoji: Value(cat.$3),
      color: Value(
        CategoryPalette.seedColors[cat.$1] ?? CategoryPalette.slate.hex,
      ),
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
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
