import 'package:drift/drift.dart';

@TableIndex(name: 'idx_goals_user_id', columns: {#userId})
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  RealColumn get savedAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  RealColumn get monthlyContribution => real().nullable()();
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
