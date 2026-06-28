part of 'record_dao.dart';

mixin _$RecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecordsTable get records => attachedDatabase.records;
}
