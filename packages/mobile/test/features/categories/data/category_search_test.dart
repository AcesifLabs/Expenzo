import 'package:drift/native.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/features/categories/data/datasources/category_local_datasource.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CategoryLocalDatasourceImpl datasource;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await DatabaseSeeder.seedInitialCategories(db);
    datasource = CategoryLocalDatasourceImpl(categoryDao: CategoryDao(db));
  });

  tearDown(() async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    await db.close();
  });

  Future<List<String?>> idsFor(String query) async => [
    for (final c in await datasource.searchCategories(
      query: query,
      type: RecordType.expense,
    ))
      c.id,
  ];

  test('finds a default category by its English name', () async {
    expect(await idsFor('food'), contains('default_out_food'));
  });

  test('finds a default category by the Bangla name shown on screen', () async {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    expect(await idsFor('খাবার'), contains('default_out_food'));
  });

  test('a query that matches nothing returns nothing', () async {
    expect(await idsFor('zzz'), isEmpty);
  });
}
