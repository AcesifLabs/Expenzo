import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/parsing_rules_table.dart';

part 'parsing_rule_dao.g.dart';

@DriftAccessor(tables: [ParsingRules])
class ParsingRuleDao extends DatabaseAccessor<AppDatabase>
    with _$ParsingRuleDaoMixin {
  ParsingRuleDao(super.db);

  Stream<List<ParsingRule>> watchRules() {
    return (select(
      parsingRules,
    )..orderBy([(t) => OrderingTerm.desc(t.priority)])).watch();
  }

  Future<List<ParsingRule>> getAllRules() {
    return (select(
      parsingRules,
    )..orderBy([(t) => OrderingTerm.desc(t.priority)])).get();
  }

  Future<List<ParsingRule>> getRulesBySourceType(String sourceType) {
    return (select(parsingRules)
          ..where((t) => t.sourceType.equals(sourceType))
          ..orderBy([(t) => OrderingTerm.desc(t.priority)]))
        .get();
  }

  Future<List<ParsingRule>> getEnabledRules() {
    return (select(parsingRules)
          ..where((t) => t.isEnabled.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.priority)]))
        .get();
  }

  Future<ParsingRule?> getRuleById(String id) {
    return (select(
      parsingRules,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertRule(ParsingRulesCompanion rule) {
    return into(parsingRules).insert(rule);
  }

  Future<bool> updateRule(ParsingRulesCompanion rule) {
    return update(
      parsingRules,
    ).replace(rule.copyWith(updatedAt: Value(DateTime.now().toUtc())));
  }

  Future<int> deleteRule(String id) {
    return (delete(parsingRules)..where((t) => t.id.equals(id))).go();
  }
}
