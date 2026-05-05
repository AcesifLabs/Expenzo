import '../../domain/entities/parsing_rule.dart' as domain;

abstract class ParsingRulesRemoteDatasource {
  Future<List<domain.ParsingRule>> getRules();
  Future<domain.ParsingRule> createRule(domain.ParsingRule rule);
  Future<domain.ParsingRule> updateRule(domain.ParsingRule rule);
  Future<void> deleteRule(String id);
  Stream<List<domain.ParsingRule>> watchRules();
}

class ParsingRulesRemoteDatasourceImpl implements ParsingRulesRemoteDatasource {
  @override
  Future<List<domain.ParsingRule>> getRules() async {
    return [];
  }

  @override
  Future<domain.ParsingRule> createRule(domain.ParsingRule rule) async {
    return rule;
  }

  @override
  Future<domain.ParsingRule> updateRule(domain.ParsingRule rule) async {
    return rule;
  }

  @override
  Future<void> deleteRule(String id) async {}

  @override
  Stream<List<domain.ParsingRule>> watchRules() {
    return const Stream.empty();
  }
}
