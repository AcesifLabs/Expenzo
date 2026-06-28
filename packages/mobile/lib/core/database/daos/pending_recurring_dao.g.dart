part of 'pending_recurring_dao.dart';

mixin _$PendingRecurringDaoMixin on DatabaseAccessor<AppDatabase> {
  $PendingRecurringTable get pendingRecurring =>
      attachedDatabase.pendingRecurring;
}
