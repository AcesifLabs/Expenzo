part of 'message_template_dao.dart';

mixin _$MessageTemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $MessageSourcesTable get messageSources => attachedDatabase.messageSources;
  $ExpenseTemplatesTable get expenseTemplates =>
      attachedDatabase.expenseTemplates;
}
