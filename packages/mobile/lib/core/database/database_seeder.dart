import 'package:drift/drift.dart';
import 'app_database.dart';

class DatabaseSeeder {
  static Future<void> seedInitialCategories(AppDatabase db) async {
    // Check if any categories exist
    final existingCategories = await db.select(db.categories).get();
    if (existingCategories.isNotEmpty) return;

    final now = DateTime.now();

    final categoriesToSeed = [
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

    await db.batch((batch) {
      for (final cat in categoriesToSeed) {
        batch.insert(
          db.categories,
          CategoriesCompanion.insert(
            name: cat.$1,
            emoji: Value(cat.$2),
            color: Value(cat.$3),
            categoryType: const Value('OUT'), isDefault: const Value(true), // Default to expense
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
