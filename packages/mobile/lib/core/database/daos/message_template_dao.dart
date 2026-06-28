import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/message_sources_table.dart';
import '../tables/expense_templates_table.dart';

part 'message_template_dao.g.dart';

@DriftAccessor(tables: [MessageSources, ExpenseTemplates])
class MessageTemplateDao extends DatabaseAccessor<AppDatabase>
    with _$MessageTemplateDaoMixin {
  MessageTemplateDao(super.db);

  Future<List<MessageSource>> getAllMessageSources() =>
      select(messageSources).get();

  Future<MessageSource?> getMessageSourceById(String id) {
    return (select(
      messageSources,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<MessageSource>> watchMessageSources() =>
      select(messageSources).watch();

  Future<void> insertMessageSource(MessageSourcesCompanion source) {
    return into(
      messageSources,
    ).insert(source, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateMessageSource(MessageSourcesCompanion source) {
    return update(messageSources).replace(source);
  }

  Future<void> deleteMessageSource(String id) {
    return (delete(messageSources)..where((t) => t.id.equals(id))).go();
  }

  Future<List<ExpenseTemplate>> getTemplatesForSource(String sourceId) {
    return (select(
      expenseTemplates,
    )..where((t) => t.sourceId.equals(sourceId))).get();
  }

  Future<List<ExpenseTemplate>> getAllTemplates() =>
      select(expenseTemplates).get();

  Stream<List<ExpenseTemplate>> watchTemplatesForSource(String sourceId) {
    return (select(
      expenseTemplates,
    )..where((t) => t.sourceId.equals(sourceId))).watch();
  }

  Future<void> insertTemplate(ExpenseTemplatesCompanion template) {
    return into(
      expenseTemplates,
    ).insert(template, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateTemplate(ExpenseTemplatesCompanion template) {
    return update(expenseTemplates).replace(template);
  }

  Future<void> deleteTemplate(String id) {
    return (delete(expenseTemplates)..where((t) => t.id.equals(id))).go();
  }
}
