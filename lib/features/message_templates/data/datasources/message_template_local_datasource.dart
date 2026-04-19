import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/message_template_dao.dart';
import '../../domain/entities/message_source.dart' as domain;
import '../../domain/entities/expense_template.dart' as domain;

abstract class MessageTemplateLocalDatasource {
  Future<List<domain.MessageSource>> getMessageSources();
  Future<domain.MessageSource?> getMessageSourceById(String id);
  Future<domain.MessageSource> saveMessageSource(domain.MessageSource source);
  Future<void> deleteMessageSource(String id);
  Stream<List<domain.MessageSource>> watchMessageSources();

  Future<List<domain.ExpenseTemplate>> getTemplatesForSource(String sourceId);
  Future<List<domain.ExpenseTemplate>> getAllTemplates();
  Future<domain.ExpenseTemplate> saveTemplate(domain.ExpenseTemplate template);
  Future<void> deleteTemplate(String id);
  Stream<List<domain.ExpenseTemplate>> watchTemplatesForSource(String sourceId);
}

class MessageTemplateLocalDatasourceImpl
    implements MessageTemplateLocalDatasource {
  final MessageTemplateDao dao;

  MessageTemplateLocalDatasourceImpl(this.dao);

  // Message Sources
  @override
  Future<List<domain.MessageSource>> getMessageSources() async {
    final sources = await dao.getAllMessageSources();
    return sources.map(_mapSourceToDomain).toList();
  }

  @override
  Future<domain.MessageSource?> getMessageSourceById(String id) async {
    final source = await dao.getMessageSourceById(id);
    return source != null ? _mapSourceToDomain(source) : null;
  }

  @override
  Future<domain.MessageSource> saveMessageSource(
    domain.MessageSource source,
  ) async {
    final companion = MessageSourcesCompanion(
      id: Value(source.id),
      contactId: Value(source.contactId),
      contactName: Value(source.contactName),
      isMonitored: Value(source.isMonitored),
      autoCreateOption: Value(source.autoCreateOption.index),
      createdAt: Value(source.createdAt),
      updatedAt: Value(source.updatedAt),
    );
    await dao.insertMessageSource(companion);
    return source;
  }

  @override
  Future<void> deleteMessageSource(String id) async {
    await dao.deleteMessageSource(id);
  }

  @override
  Stream<List<domain.MessageSource>> watchMessageSources() {
    return dao.watchMessageSources().map(
      (list) => list.map(_mapSourceToDomain).toList(),
    );
  }

  // Expense Templates
  @override
  Future<List<domain.ExpenseTemplate>> getTemplatesForSource(
    String sourceId,
  ) async {
    final templates = await dao.getTemplatesForSource(sourceId);
    return templates.map(_mapTemplateToDomain).toList();
  }

  @override
  Future<List<domain.ExpenseTemplate>> getAllTemplates() async {
    final templates = await dao.getAllTemplates();
    return templates.map(_mapTemplateToDomain).toList();
  }

  @override
  Future<domain.ExpenseTemplate> saveTemplate(
    domain.ExpenseTemplate template,
  ) async {
    final companion = ExpenseTemplatesCompanion(
      id: Value(template.id),
      sourceId: Value(template.sourceId),
      sampleMessage: Value(template.sampleMessage),
      triggerWord: Value(template.triggerWord),
      amountPattern: Value(template.amountPattern),
      descriptionPattern: Value(template.descriptionPattern),
      datePattern: Value(template.datePattern),
      categoryId: Value(template.categoryId),
      selectedAmount: Value(template.selectedAmount),
      createdAt: Value(template.createdAt),
      updatedAt: Value(template.updatedAt),
    );
    await dao.insertTemplate(companion);
    return template;
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await dao.deleteTemplate(id);
  }

  @override
  Stream<List<domain.ExpenseTemplate>> watchTemplatesForSource(
    String sourceId,
  ) {
    return dao
        .watchTemplatesForSource(sourceId)
        .map((list) => list.map(_mapTemplateToDomain).toList());
  }

  // Mappers
  domain.MessageSource _mapSourceToDomain(MessageSource source) {
    return domain.MessageSource(
      id: source.id,
      contactId: source.contactId,
      contactName: source.contactName,
      isMonitored: source.isMonitored,
      autoCreateOption: domain.AutoCreateOption.values[source.autoCreateOption],
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
    );
  }

  domain.ExpenseTemplate _mapTemplateToDomain(ExpenseTemplate template) {
    return domain.ExpenseTemplate(
      id: template.id,
      sourceId: template.sourceId,
      sampleMessage: template.sampleMessage,
      triggerWord: template.triggerWord,
      amountPattern: template.amountPattern,
      descriptionPattern: template.descriptionPattern,
      datePattern: template.datePattern,
      categoryId: template.categoryId,
      selectedAmount: template.selectedAmount,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
  }
}
