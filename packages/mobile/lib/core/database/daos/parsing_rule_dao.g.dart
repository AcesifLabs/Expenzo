// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsing_rule_dao.dart';

// ignore_for_file: type=lint
mixin _$ParsingRuleDaoMixin on DatabaseAccessor<AppDatabase> {
  $ParsingRulesTable get parsingRules => attachedDatabase.parsingRules;
  ParsingRuleDaoManager get managers => ParsingRuleDaoManager(this);
}

class ParsingRuleDaoManager {
  final _$ParsingRuleDaoMixin _db;
  ParsingRuleDaoManager(this._db);
  $$ParsingRulesTableTableManager get parsingRules =>
      $$ParsingRulesTableTableManager(_db.attachedDatabase, _db.parsingRules);
}
