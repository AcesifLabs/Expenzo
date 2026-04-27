import 'package:drift/drift.dart';
import '../../constants/source_types.dart';

class ParsingRules extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get triggerWords => text()();
  TextColumn get amountPattern => text()();
  TextColumn get datePattern => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get sourceType => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
