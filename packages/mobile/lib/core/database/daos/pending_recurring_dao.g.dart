// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_recurring_dao.dart';

// ignore_for_file: type=lint
mixin _$PendingRecurringDaoMixin on DatabaseAccessor<AppDatabase> {
  $PendingRecurringTable get pendingRecurring =>
      attachedDatabase.pendingRecurring;
  PendingRecurringDaoManager get managers => PendingRecurringDaoManager(this);
}

class PendingRecurringDaoManager {
  final _$PendingRecurringDaoMixin _db;
  PendingRecurringDaoManager(this._db);
  $$PendingRecurringTableTableManager get pendingRecurring =>
      $$PendingRecurringTableTableManager(
        _db.attachedDatabase,
        _db.pendingRecurring,
      );
}
