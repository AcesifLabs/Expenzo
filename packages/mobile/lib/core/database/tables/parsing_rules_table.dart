import 'package:drift/drift.dart';

@TableIndex(name: 'idx_parsing_rules_cat_id', columns: {#categoryId})
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

  late final TextColumn dateOrder = text()
      .withDefault(const Constant('dmy'))
      .check(dateOrder.isIn(const ['dmy', 'mdy']))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
