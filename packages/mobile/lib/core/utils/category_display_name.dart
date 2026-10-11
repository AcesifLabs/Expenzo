import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Stored name for records without a category in report and summary data.
const uncategorizedName = 'Uncategorized';

/// The name to show for a category in the current app language.
///
/// Stored names stay English (they sync and feed receipt matching). A seeded
/// default category is translated only while its name is the untouched seed
/// name; once the user renames it, their text is shown as typed.
String categoryDisplayName({required String? id, required String name}) {
  if (name == uncategorizedName && DatabaseSeeder.seedNames[id] == null) {
    return t.categories.uncategorized;
  }
  if (id == null || DatabaseSeeder.seedNames[id] != name) return name;

  return t.categories.defaults[id] ?? name;
}
