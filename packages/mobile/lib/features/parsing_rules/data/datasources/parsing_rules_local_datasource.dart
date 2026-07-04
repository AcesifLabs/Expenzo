import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/parsing_rule_dao.dart';
import '../../domain/entities/parsing_rule.dart' as domain;

abstract class ParsingRulesLocalDatasource {
  /// Throws: [CacheException] if a database error occurs.
  Future<List<domain.ParsingRule>> getRules({
    domain.SourceType? sourceType,
    bool? isEnabled,
  });
  Future<domain.ParsingRule?> getRuleById(String id);

  /// Throws: [CacheException] if a database error occurs.
  Future<domain.ParsingRule> createRule(domain.ParsingRule rule);
  Future<domain.ParsingRule> updateRule(domain.ParsingRule rule);
  Future<void> deleteRule(String id);
  Stream<List<domain.ParsingRule>> watchRules();
}

class ParsingRulesLocalDatasourceImpl implements ParsingRulesLocalDatasource {
  final ParsingRuleDao dao;

  ParsingRulesLocalDatasourceImpl(this.dao);

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<domain.ParsingRule>> getRules({
    domain.SourceType? sourceType,
    bool? isEnabled,
  }) async {
    if (isEnabled == true) {
      final rules = await dao.getEnabledRules();

      return rules.map(_mapToEntity).toList();
    }
    if (sourceType != null) {
      final rules = await dao.getRulesBySourceType(sourceType.name);

      return rules.map(_mapToEntity).toList();
    }
    final rules = await dao.getAllRules();

    return rules.map(_mapToEntity).toList();
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<domain.ParsingRule?> getRuleById(String id) async {
    final rule = await dao.getRuleById(id);

    return rule != null ? _mapToEntity(rule) : null;
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<domain.ParsingRule> createRule(domain.ParsingRule rule) async {
    final companion = _toCompanion(rule);
    await dao.insertRule(companion);

    return rule;
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<domain.ParsingRule> updateRule(domain.ParsingRule rule) async {
    final companion = _toCompanion(rule);
    await dao.updateRule(companion);

    return rule;
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> deleteRule(String id) async {
    await dao.deleteRule(id);
  }

  @override
  Stream<List<domain.ParsingRule>> watchRules() {
    return dao.watchRules().map((rules) => rules.map(_mapToEntity).toList());
  }

  domain.ParsingRule _mapToEntity(ParsingRule data) {
    return domain.ParsingRule(
      id: data.id,
      name: data.name,
      triggerWords: List<String>.from(json.decode(data.triggerWords)),
      amountPattern: data.amountPattern,
      datePattern: data.datePattern,
      categoryId: data.categoryId,
      sourceType: domain.SourceType.values.firstWhere(
        (e) => e.name == data.sourceType,
        orElse: () => domain.SourceType.both,
      ),
      isEnabled: data.isEnabled,
      priority: data.priority,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  ParsingRulesCompanion _toCompanion(domain.ParsingRule rule) {
    return ParsingRulesCompanion(
      id: Value(rule.id),
      name: Value(rule.name),
      triggerWords: Value(json.encode(rule.triggerWords)),
      amountPattern: Value(rule.amountPattern),
      datePattern: Value(rule.datePattern),
      categoryId: Value(rule.categoryId),
      sourceType: Value(rule.sourceType.name),
      isEnabled: Value(rule.isEnabled),
      priority: Value(rule.priority),
      createdAt: Value(rule.createdAt),
      updatedAt: Value(rule.updatedAt),
    );
  }
}
