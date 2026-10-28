// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_template_dao.dart';

// ignore_for_file: type=lint
mixin _$MessageTemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $MessageSourcesTable get messageSources => attachedDatabase.messageSources;
  $ExpenseTemplatesTable get expenseTemplates =>
      attachedDatabase.expenseTemplates;
  MessageTemplateDaoManager get managers => MessageTemplateDaoManager(this);
}

class MessageTemplateDaoManager {
  final _$MessageTemplateDaoMixin _db;
  MessageTemplateDaoManager(this._db);
  $$MessageSourcesTableTableManager get messageSources =>
      $$MessageSourcesTableTableManager(
        _db.attachedDatabase,
        _db.messageSources,
      );
  $$ExpenseTemplatesTableTableManager get expenseTemplates =>
      $$ExpenseTemplatesTableTableManager(
        _db.attachedDatabase,
        _db.expenseTemplates,
      );
}
