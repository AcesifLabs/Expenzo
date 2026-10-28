import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

const uncategorizedName = 'Uncategorized';

String categoryDisplayName({required String? id, required String name}) {
  if (name == uncategorizedName && DatabaseSeeder.seedNames[id] == null) {
    return t.categories.uncategorized;
  }
  if (id == null || DatabaseSeeder.seedNames[id] != name) return name;

  return t.categories.defaults[id] ?? name;
}
