part of 'recurring_dao.dart';

mixin _$RecurringDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecurringTransactionsTable get recurringTransactions =>
      attachedDatabase.recurringTransactions;
}
