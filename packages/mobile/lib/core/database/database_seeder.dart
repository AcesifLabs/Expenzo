import 'package:drift/drift.dart';
import 'app_database.dart';

class DatabaseSeeder {
  static const _incomeCategories = [
    ('Salary', 'briefcase', '#43A047'),
    ('Freelance', 'laptop', '#00ACC1'),
    ('Investment', 'chartLineUp', '#7CB342'),
    ('Refund', 'arrowULeftDown', '#FF9800'),
    ('Gift', 'gift', '#FFB300'),
    ('General', 'package', '#1E88E5'),
  ];

  static Future<void> seedInitialCategories(AppDatabase db) async {
    // Check if any categories exist
    final existingCategories = await db.select(db.categories).get();
    if (existingCategories.isNotEmpty) {
      // Ensure all income categories exist for existing users
      await _ensureIncomeCategoriesExist(db);
      return;
    }

    final now = DateTime.now();

    // Expense categories
    final expenseCategories = [
      ('Food', 'forkKnife', '#FF9800'),
      ('Shopping', 'shoppingCart', '#D81B60'),
      ('Transport', 'car', '#00ACC1'),
      ('Home', 'house', '#5E35B1'),
      ('Health', 'heartbeat', '#E53935'),
      ('Entertainment', 'gameController', '#43A047'),
      ('Bills', 'deviceMobile', '#FDD835'),
      ('Travel', 'airplane', '#3949AB'),
      ('Education', 'graduationCap', '#00897B'),
      ('Investment', 'currencyDollar', '#7CB342'),
      ('Gifts', 'gift', '#FFB300'),
      ('General', 'package', '#1E88E5'),
    ];

    // Income categories
    final incomeCategories = _incomeCategories;

    await db.batch((batch) {
      for (final cat in expenseCategories) {
        batch.insert(
          db.categories,
          CategoriesCompanion.insert(
            name: cat.$1,
            emoji: Value(cat.$2),
            color: Value(cat.$3),
            categoryType: const Value('OUT'),
            isDefault: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
      for (final cat in incomeCategories) {
        batch.insert(
          db.categories,
          CategoriesCompanion.insert(
            name: cat.$1,
            emoji: Value(cat.$2),
            color: Value(cat.$3),
            categoryType: const Value('IN'),
            isDefault: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  /// Ensures all income categories exist for existing users who were seeded
  /// before income category support was added.
  static Future<void> _ensureIncomeCategoriesExist(AppDatabase db) async {
    // Query all existing IN-category names to avoid inserting duplicates
    final existingIn = await (db.select(db.categories)
          ..where((t) => t.categoryType.equals('IN')))
        .get();
    final existingNames = existingIn.map((c) => c.name).toSet();

    final missing = _incomeCategories
        .where((cat) => !existingNames.contains(cat.$1))
        .toList();

    if (missing.isEmpty) return;

    final now = DateTime.now();

    await db.batch((batch) {
      for (final cat in missing) {
        batch.insert(
          db.categories,
          CategoriesCompanion.insert(
            name: cat.$1,
            emoji: Value(cat.$2),
            color: Value(cat.$3),
            categoryType: const Value('IN'),
            isDefault: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
