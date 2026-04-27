// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecordsTable extends Records with TableInfo<$RecordsTable, Record> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordTypeMeta =
      const VerificationMeta('recordType');
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
      'record_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        description,
        date,
        categoryId,
        source,
        sourceId,
        recordType,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'records';
  @override
  VerificationContext validateIntegrity(Insertable<Record> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('record_type')) {
      context.handle(
          _recordTypeMeta,
          recordType.isAcceptableOrUnknown(
              data['record_type']!, _recordTypeMeta));
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Record map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Record(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      recordType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RecordsTable createAlias(String alias) {
    return $RecordsTable(attachedDatabase, alias);
  }
}

class Record extends DataClass implements Insertable<Record> {
  final int id;
  final double amount;
  final String description;
  final DateTime date;
  final int? categoryId;
  final String source;
  final String? sourceId;
  final String recordType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Record(
      {required this.id,
      required this.amount,
      required this.description,
      required this.date,
      this.categoryId,
      required this.source,
      this.sourceId,
      required this.recordType,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['record_type'] = Variable<String>(recordType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecordsCompanion toCompanion(bool nullToAbsent) {
    return RecordsCompanion(
      id: Value(id),
      amount: Value(amount),
      description: Value(description),
      date: Value(date),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      recordType: Value(recordType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Record.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Record(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'date': serializer.toJson<DateTime>(date),
      'categoryId': serializer.toJson<int?>(categoryId),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'recordType': serializer.toJson<String>(recordType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Record copyWith(
          {int? id,
          double? amount,
          String? description,
          DateTime? date,
          Value<int?> categoryId = const Value.absent(),
          String? source,
          Value<String?> sourceId = const Value.absent(),
          String? recordType,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Record(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        date: date ?? this.date,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        source: source ?? this.source,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        recordType: recordType ?? this.recordType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Record copyWithCompanion(RecordsCompanion data) {
    return Record(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      recordType:
          data.recordType.present ? data.recordType.value : this.recordType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Record(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('recordType: $recordType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, description, date, categoryId,
      source, sourceId, recordType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Record &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.categoryId == this.categoryId &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.recordType == this.recordType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecordsCompanion extends UpdateCompanion<Record> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> description;
  final Value<DateTime> date;
  final Value<int?> categoryId;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<String> recordType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RecordsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RecordsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String description,
    required DateTime date,
    this.categoryId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String recordType,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : amount = Value(amount),
        description = Value(description),
        date = Value(date),
        recordType = Value(recordType);
  static Insertable<Record> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<int>? categoryId,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? recordType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (categoryId != null) 'category_id': categoryId,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (recordType != null) 'record_type': recordType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RecordsCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<String>? description,
      Value<DateTime>? date,
      Value<int?>? categoryId,
      Value<String>? source,
      Value<String?>? sourceId,
      Value<String>? recordType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return RecordsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      recordType: recordType ?? this.recordType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('recordType: $recordType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('package'));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#2196F3'));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryTypeMeta =
      const VerificationMeta('categoryType');
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
      'category_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('OUT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, emoji, color, isDefault, categoryType, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('category_type')) {
      context.handle(
          _categoryTypeMeta,
          categoryType.isAcceptableOrUnknown(
              data['category_type']!, _categoryTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      categoryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String emoji;
  final String color;
  final bool isDefault;
  final String categoryType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Category(
      {required this.id,
      required this.name,
      required this.emoji,
      required this.color,
      required this.isDefault,
      required this.categoryType,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<String>(color);
    map['is_default'] = Variable<bool>(isDefault);
    map['category_type'] = Variable<String>(categoryType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
      isDefault: Value(isDefault),
      categoryType: Value(categoryType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<String>(json['color']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      categoryType: serializer.fromJson<String>(json['categoryType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<String>(color),
      'isDefault': serializer.toJson<bool>(isDefault),
      'categoryType': serializer.toJson<String>(categoryType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith(
          {int? id,
          String? name,
          String? emoji,
          String? color,
          bool? isDefault,
          String? categoryType,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        color: color ?? this.color,
        isDefault: isDefault ?? this.isDefault,
        categoryType: categoryType ?? this.categoryType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      categoryType: data.categoryType.present
          ? data.categoryType.value
          : this.categoryType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('categoryType: $categoryType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, emoji, color, isDefault, categoryType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.isDefault == this.isDefault &&
          other.categoryType == this.categoryType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<String> color;
  final Value<bool> isDefault;
  final Value<String> categoryType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? color,
    Expression<bool>? isDefault,
    Expression<String>? categoryType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (isDefault != null) 'is_default': isDefault,
      if (categoryType != null) 'category_type': categoryType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? emoji,
      Value<String>? color,
      Value<bool>? isDefault,
      Value<String>? categoryType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      categoryType: categoryType ?? this.categoryType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(categoryType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('categoryType: $categoryType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PendingRecurringTable extends PendingRecurring
    with TableInfo<$PendingRecurringTable, PendingRecurringData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingRecurringTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recurringIdMeta =
      const VerificationMeta('recurringId');
  @override
  late final GeneratedColumn<String> recurringId = GeneratedColumn<String>(
      'recurring_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recurringId, dueDate, amount, description, categoryId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_recurring';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingRecurringData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recurring_id')) {
      context.handle(
          _recurringIdMeta,
          recurringId.isAcceptableOrUnknown(
              data['recurring_id']!, _recurringIdMeta));
    } else if (isInserting) {
      context.missing(_recurringIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingRecurringData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingRecurringData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recurringId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurring_id'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingRecurringTable createAlias(String alias) {
    return $PendingRecurringTable(attachedDatabase, alias);
  }
}

class PendingRecurringData extends DataClass
    implements Insertable<PendingRecurringData> {
  final int id;
  final String recurringId;
  final DateTime dueDate;
  final double amount;
  final String description;
  final String? categoryId;
  final DateTime createdAt;
  const PendingRecurringData(
      {required this.id,
      required this.recurringId,
      required this.dueDate,
      required this.amount,
      required this.description,
      this.categoryId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recurring_id'] = Variable<String>(recurringId);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingRecurringCompanion toCompanion(bool nullToAbsent) {
    return PendingRecurringCompanion(
      id: Value(id),
      recurringId: Value(recurringId),
      dueDate: Value(dueDate),
      amount: Value(amount),
      description: Value(description),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      createdAt: Value(createdAt),
    );
  }

  factory PendingRecurringData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingRecurringData(
      id: serializer.fromJson<int>(json['id']),
      recurringId: serializer.fromJson<String>(json['recurringId']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recurringId': serializer.toJson<String>(recurringId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<String?>(categoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingRecurringData copyWith(
          {int? id,
          String? recurringId,
          DateTime? dueDate,
          double? amount,
          String? description,
          Value<String?> categoryId = const Value.absent(),
          DateTime? createdAt}) =>
      PendingRecurringData(
        id: id ?? this.id,
        recurringId: recurringId ?? this.recurringId,
        dueDate: dueDate ?? this.dueDate,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingRecurringData copyWithCompanion(PendingRecurringCompanion data) {
    return PendingRecurringData(
      id: data.id.present ? data.id.value : this.id,
      recurringId:
          data.recurringId.present ? data.recurringId.value : this.recurringId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingRecurringData(')
          ..write('id: $id, ')
          ..write('recurringId: $recurringId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, recurringId, dueDate, amount, description, categoryId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingRecurringData &&
          other.id == this.id &&
          other.recurringId == this.recurringId &&
          other.dueDate == this.dueDate &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.createdAt == this.createdAt);
}

class PendingRecurringCompanion extends UpdateCompanion<PendingRecurringData> {
  final Value<int> id;
  final Value<String> recurringId;
  final Value<DateTime> dueDate;
  final Value<double> amount;
  final Value<String> description;
  final Value<String?> categoryId;
  final Value<DateTime> createdAt;
  const PendingRecurringCompanion({
    this.id = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingRecurringCompanion.insert({
    this.id = const Value.absent(),
    required String recurringId,
    required DateTime dueDate,
    required double amount,
    required String description,
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : recurringId = Value(recurringId),
        dueDate = Value(dueDate),
        amount = Value(amount),
        description = Value(description);
  static Insertable<PendingRecurringData> custom({
    Expression<int>? id,
    Expression<String>? recurringId,
    Expression<DateTime>? dueDate,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recurringId != null) 'recurring_id': recurringId,
      if (dueDate != null) 'due_date': dueDate,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingRecurringCompanion copyWith(
      {Value<int>? id,
      Value<String>? recurringId,
      Value<DateTime>? dueDate,
      Value<double>? amount,
      Value<String>? description,
      Value<String?>? categoryId,
      Value<DateTime>? createdAt}) {
    return PendingRecurringCompanion(
      id: id ?? this.id,
      recurringId: recurringId ?? this.recurringId,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recurringId.present) {
      map['recurring_id'] = Variable<String>(recurringId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingRecurringCompanion(')
          ..write('id: $id, ')
          ..write('recurringId: $recurringId, ')
          ..write('dueDate: $dueDate, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ParsingRulesTable extends ParsingRules
    with TableInfo<$ParsingRulesTable, ParsingRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParsingRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggerWordsMeta =
      const VerificationMeta('triggerWords');
  @override
  late final GeneratedColumn<String> triggerWords = GeneratedColumn<String>(
      'trigger_words', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountPatternMeta =
      const VerificationMeta('amountPattern');
  @override
  late final GeneratedColumn<String> amountPattern = GeneratedColumn<String>(
      'amount_pattern', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _datePatternMeta =
      const VerificationMeta('datePattern');
  @override
  late final GeneratedColumn<String> datePattern = GeneratedColumn<String>(
      'date_pattern', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        triggerWords,
        amountPattern,
        datePattern,
        categoryId,
        sourceType,
        isEnabled,
        priority,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parsing_rules';
  @override
  VerificationContext validateIntegrity(Insertable<ParsingRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('trigger_words')) {
      context.handle(
          _triggerWordsMeta,
          triggerWords.isAcceptableOrUnknown(
              data['trigger_words']!, _triggerWordsMeta));
    } else if (isInserting) {
      context.missing(_triggerWordsMeta);
    }
    if (data.containsKey('amount_pattern')) {
      context.handle(
          _amountPatternMeta,
          amountPattern.isAcceptableOrUnknown(
              data['amount_pattern']!, _amountPatternMeta));
    } else if (isInserting) {
      context.missing(_amountPatternMeta);
    }
    if (data.containsKey('date_pattern')) {
      context.handle(
          _datePatternMeta,
          datePattern.isAcceptableOrUnknown(
              data['date_pattern']!, _datePatternMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParsingRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParsingRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      triggerWords: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_words'])!,
      amountPattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount_pattern'])!,
      datePattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_pattern']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ParsingRulesTable createAlias(String alias) {
    return $ParsingRulesTable(attachedDatabase, alias);
  }
}

class ParsingRule extends DataClass implements Insertable<ParsingRule> {
  final String id;
  final String name;
  final String triggerWords;
  final String amountPattern;
  final String? datePattern;
  final String? categoryId;
  final String sourceType;
  final bool isEnabled;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ParsingRule(
      {required this.id,
      required this.name,
      required this.triggerWords,
      required this.amountPattern,
      this.datePattern,
      this.categoryId,
      required this.sourceType,
      required this.isEnabled,
      required this.priority,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['trigger_words'] = Variable<String>(triggerWords);
    map['amount_pattern'] = Variable<String>(amountPattern);
    if (!nullToAbsent || datePattern != null) {
      map['date_pattern'] = Variable<String>(datePattern);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['source_type'] = Variable<String>(sourceType);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ParsingRulesCompanion toCompanion(bool nullToAbsent) {
    return ParsingRulesCompanion(
      id: Value(id),
      name: Value(name),
      triggerWords: Value(triggerWords),
      amountPattern: Value(amountPattern),
      datePattern: datePattern == null && nullToAbsent
          ? const Value.absent()
          : Value(datePattern),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      sourceType: Value(sourceType),
      isEnabled: Value(isEnabled),
      priority: Value(priority),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ParsingRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParsingRule(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      triggerWords: serializer.fromJson<String>(json['triggerWords']),
      amountPattern: serializer.fromJson<String>(json['amountPattern']),
      datePattern: serializer.fromJson<String?>(json['datePattern']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'triggerWords': serializer.toJson<String>(triggerWords),
      'amountPattern': serializer.toJson<String>(amountPattern),
      'datePattern': serializer.toJson<String?>(datePattern),
      'categoryId': serializer.toJson<String?>(categoryId),
      'sourceType': serializer.toJson<String>(sourceType),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ParsingRule copyWith(
          {String? id,
          String? name,
          String? triggerWords,
          String? amountPattern,
          Value<String?> datePattern = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          String? sourceType,
          bool? isEnabled,
          int? priority,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ParsingRule(
        id: id ?? this.id,
        name: name ?? this.name,
        triggerWords: triggerWords ?? this.triggerWords,
        amountPattern: amountPattern ?? this.amountPattern,
        datePattern: datePattern.present ? datePattern.value : this.datePattern,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        sourceType: sourceType ?? this.sourceType,
        isEnabled: isEnabled ?? this.isEnabled,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ParsingRule copyWithCompanion(ParsingRulesCompanion data) {
    return ParsingRule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      triggerWords: data.triggerWords.present
          ? data.triggerWords.value
          : this.triggerWords,
      amountPattern: data.amountPattern.present
          ? data.amountPattern.value
          : this.amountPattern,
      datePattern:
          data.datePattern.present ? data.datePattern.value : this.datePattern,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParsingRule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('triggerWords: $triggerWords, ')
          ..write('amountPattern: $amountPattern, ')
          ..write('datePattern: $datePattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('sourceType: $sourceType, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      triggerWords,
      amountPattern,
      datePattern,
      categoryId,
      sourceType,
      isEnabled,
      priority,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParsingRule &&
          other.id == this.id &&
          other.name == this.name &&
          other.triggerWords == this.triggerWords &&
          other.amountPattern == this.amountPattern &&
          other.datePattern == this.datePattern &&
          other.categoryId == this.categoryId &&
          other.sourceType == this.sourceType &&
          other.isEnabled == this.isEnabled &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ParsingRulesCompanion extends UpdateCompanion<ParsingRule> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> triggerWords;
  final Value<String> amountPattern;
  final Value<String?> datePattern;
  final Value<String?> categoryId;
  final Value<String> sourceType;
  final Value<bool> isEnabled;
  final Value<int> priority;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ParsingRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.triggerWords = const Value.absent(),
    this.amountPattern = const Value.absent(),
    this.datePattern = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParsingRulesCompanion.insert({
    required String id,
    required String name,
    required String triggerWords,
    required String amountPattern,
    this.datePattern = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String sourceType,
    this.isEnabled = const Value.absent(),
    this.priority = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        triggerWords = Value(triggerWords),
        amountPattern = Value(amountPattern),
        sourceType = Value(sourceType),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ParsingRule> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? triggerWords,
    Expression<String>? amountPattern,
    Expression<String>? datePattern,
    Expression<String>? categoryId,
    Expression<String>? sourceType,
    Expression<bool>? isEnabled,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (triggerWords != null) 'trigger_words': triggerWords,
      if (amountPattern != null) 'amount_pattern': amountPattern,
      if (datePattern != null) 'date_pattern': datePattern,
      if (categoryId != null) 'category_id': categoryId,
      if (sourceType != null) 'source_type': sourceType,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParsingRulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? triggerWords,
      Value<String>? amountPattern,
      Value<String?>? datePattern,
      Value<String?>? categoryId,
      Value<String>? sourceType,
      Value<bool>? isEnabled,
      Value<int>? priority,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ParsingRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      triggerWords: triggerWords ?? this.triggerWords,
      amountPattern: amountPattern ?? this.amountPattern,
      datePattern: datePattern ?? this.datePattern,
      categoryId: categoryId ?? this.categoryId,
      sourceType: sourceType ?? this.sourceType,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (triggerWords.present) {
      map['trigger_words'] = Variable<String>(triggerWords.value);
    }
    if (amountPattern.present) {
      map['amount_pattern'] = Variable<String>(amountPattern.value);
    }
    if (datePattern.present) {
      map['date_pattern'] = Variable<String>(datePattern.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParsingRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('triggerWords: $triggerWords, ')
          ..write('amountPattern: $amountPattern, ')
          ..write('datePattern: $datePattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('sourceType: $sourceType, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageSourcesTable extends MessageSources
    with TableInfo<$MessageSourcesTable, MessageSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactNameMeta =
      const VerificationMeta('contactName');
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
      'contact_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isMonitoredMeta =
      const VerificationMeta('isMonitored');
  @override
  late final GeneratedColumn<bool> isMonitored = GeneratedColumn<bool>(
      'is_monitored', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_monitored" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autoCreateOptionMeta =
      const VerificationMeta('autoCreateOption');
  @override
  late final GeneratedColumn<int> autoCreateOption = GeneratedColumn<int>(
      'auto_create_option', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contactId,
        contactName,
        isMonitored,
        autoCreateOption,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_sources';
  @override
  VerificationContext validateIntegrity(Insertable<MessageSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('contact_name')) {
      context.handle(
          _contactNameMeta,
          contactName.isAcceptableOrUnknown(
              data['contact_name']!, _contactNameMeta));
    } else if (isInserting) {
      context.missing(_contactNameMeta);
    }
    if (data.containsKey('is_monitored')) {
      context.handle(
          _isMonitoredMeta,
          isMonitored.isAcceptableOrUnknown(
              data['is_monitored']!, _isMonitoredMeta));
    }
    if (data.containsKey('auto_create_option')) {
      context.handle(
          _autoCreateOptionMeta,
          autoCreateOption.isAcceptableOrUnknown(
              data['auto_create_option']!, _autoCreateOptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageSource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_id'])!,
      contactName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_name'])!,
      isMonitored: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_monitored'])!,
      autoCreateOption: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}auto_create_option'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MessageSourcesTable createAlias(String alias) {
    return $MessageSourcesTable(attachedDatabase, alias);
  }
}

class MessageSource extends DataClass implements Insertable<MessageSource> {
  final String id;
  final String contactId;
  final String contactName;
  final bool isMonitored;
  final int autoCreateOption;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MessageSource(
      {required this.id,
      required this.contactId,
      required this.contactName,
      required this.isMonitored,
      required this.autoCreateOption,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['contact_name'] = Variable<String>(contactName);
    map['is_monitored'] = Variable<bool>(isMonitored);
    map['auto_create_option'] = Variable<int>(autoCreateOption);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MessageSourcesCompanion toCompanion(bool nullToAbsent) {
    return MessageSourcesCompanion(
      id: Value(id),
      contactId: Value(contactId),
      contactName: Value(contactName),
      isMonitored: Value(isMonitored),
      autoCreateOption: Value(autoCreateOption),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MessageSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageSource(
      id: serializer.fromJson<String>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      contactName: serializer.fromJson<String>(json['contactName']),
      isMonitored: serializer.fromJson<bool>(json['isMonitored']),
      autoCreateOption: serializer.fromJson<int>(json['autoCreateOption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contactId': serializer.toJson<String>(contactId),
      'contactName': serializer.toJson<String>(contactName),
      'isMonitored': serializer.toJson<bool>(isMonitored),
      'autoCreateOption': serializer.toJson<int>(autoCreateOption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MessageSource copyWith(
          {String? id,
          String? contactId,
          String? contactName,
          bool? isMonitored,
          int? autoCreateOption,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MessageSource(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        contactName: contactName ?? this.contactName,
        isMonitored: isMonitored ?? this.isMonitored,
        autoCreateOption: autoCreateOption ?? this.autoCreateOption,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MessageSource copyWithCompanion(MessageSourcesCompanion data) {
    return MessageSource(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      contactName:
          data.contactName.present ? data.contactName.value : this.contactName,
      isMonitored:
          data.isMonitored.present ? data.isMonitored.value : this.isMonitored,
      autoCreateOption: data.autoCreateOption.present
          ? data.autoCreateOption.value
          : this.autoCreateOption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageSource(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('contactName: $contactName, ')
          ..write('isMonitored: $isMonitored, ')
          ..write('autoCreateOption: $autoCreateOption, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactId, contactName, isMonitored,
      autoCreateOption, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageSource &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.contactName == this.contactName &&
          other.isMonitored == this.isMonitored &&
          other.autoCreateOption == this.autoCreateOption &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessageSourcesCompanion extends UpdateCompanion<MessageSource> {
  final Value<String> id;
  final Value<String> contactId;
  final Value<String> contactName;
  final Value<bool> isMonitored;
  final Value<int> autoCreateOption;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MessageSourcesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.contactName = const Value.absent(),
    this.isMonitored = const Value.absent(),
    this.autoCreateOption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageSourcesCompanion.insert({
    required String id,
    required String contactId,
    required String contactName,
    this.isMonitored = const Value.absent(),
    this.autoCreateOption = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        contactId = Value(contactId),
        contactName = Value(contactName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MessageSource> custom({
    Expression<String>? id,
    Expression<String>? contactId,
    Expression<String>? contactName,
    Expression<bool>? isMonitored,
    Expression<int>? autoCreateOption,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (contactName != null) 'contact_name': contactName,
      if (isMonitored != null) 'is_monitored': isMonitored,
      if (autoCreateOption != null) 'auto_create_option': autoCreateOption,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageSourcesCompanion copyWith(
      {Value<String>? id,
      Value<String>? contactId,
      Value<String>? contactName,
      Value<bool>? isMonitored,
      Value<int>? autoCreateOption,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MessageSourcesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      isMonitored: isMonitored ?? this.isMonitored,
      autoCreateOption: autoCreateOption ?? this.autoCreateOption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (contactName.present) {
      map['contact_name'] = Variable<String>(contactName.value);
    }
    if (isMonitored.present) {
      map['is_monitored'] = Variable<bool>(isMonitored.value);
    }
    if (autoCreateOption.present) {
      map['auto_create_option'] = Variable<int>(autoCreateOption.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageSourcesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('contactName: $contactName, ')
          ..write('isMonitored: $isMonitored, ')
          ..write('autoCreateOption: $autoCreateOption, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseTemplatesTable extends ExpenseTemplates
    with TableInfo<$ExpenseTemplatesTable, ExpenseTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES message_sources (id)'));
  static const VerificationMeta _sampleMessageMeta =
      const VerificationMeta('sampleMessage');
  @override
  late final GeneratedColumn<String> sampleMessage = GeneratedColumn<String>(
      'sample_message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggerWordMeta =
      const VerificationMeta('triggerWord');
  @override
  late final GeneratedColumn<String> triggerWord = GeneratedColumn<String>(
      'trigger_word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountPatternMeta =
      const VerificationMeta('amountPattern');
  @override
  late final GeneratedColumn<String> amountPattern = GeneratedColumn<String>(
      'amount_pattern', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionPatternMeta =
      const VerificationMeta('descriptionPattern');
  @override
  late final GeneratedColumn<String> descriptionPattern =
      GeneratedColumn<String>('description_pattern', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _datePatternMeta =
      const VerificationMeta('datePattern');
  @override
  late final GeneratedColumn<String> datePattern = GeneratedColumn<String>(
      'date_pattern', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _selectedAmountMeta =
      const VerificationMeta('selectedAmount');
  @override
  late final GeneratedColumn<String> selectedAmount = GeneratedColumn<String>(
      'selected_amount', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceId,
        sampleMessage,
        triggerWord,
        amountPattern,
        descriptionPattern,
        datePattern,
        categoryId,
        selectedAmount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_templates';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('sample_message')) {
      context.handle(
          _sampleMessageMeta,
          sampleMessage.isAcceptableOrUnknown(
              data['sample_message']!, _sampleMessageMeta));
    } else if (isInserting) {
      context.missing(_sampleMessageMeta);
    }
    if (data.containsKey('trigger_word')) {
      context.handle(
          _triggerWordMeta,
          triggerWord.isAcceptableOrUnknown(
              data['trigger_word']!, _triggerWordMeta));
    } else if (isInserting) {
      context.missing(_triggerWordMeta);
    }
    if (data.containsKey('amount_pattern')) {
      context.handle(
          _amountPatternMeta,
          amountPattern.isAcceptableOrUnknown(
              data['amount_pattern']!, _amountPatternMeta));
    } else if (isInserting) {
      context.missing(_amountPatternMeta);
    }
    if (data.containsKey('description_pattern')) {
      context.handle(
          _descriptionPatternMeta,
          descriptionPattern.isAcceptableOrUnknown(
              data['description_pattern']!, _descriptionPatternMeta));
    }
    if (data.containsKey('date_pattern')) {
      context.handle(
          _datePatternMeta,
          datePattern.isAcceptableOrUnknown(
              data['date_pattern']!, _datePatternMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('selected_amount')) {
      context.handle(
          _selectedAmountMeta,
          selectedAmount.isAcceptableOrUnknown(
              data['selected_amount']!, _selectedAmountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      sampleMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sample_message'])!,
      triggerWord: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_word'])!,
      amountPattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount_pattern'])!,
      descriptionPattern: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}description_pattern']),
      datePattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_pattern']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      selectedAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selected_amount']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ExpenseTemplatesTable createAlias(String alias) {
    return $ExpenseTemplatesTable(attachedDatabase, alias);
  }
}

class ExpenseTemplate extends DataClass implements Insertable<ExpenseTemplate> {
  final String id;
  final String sourceId;
  final String sampleMessage;
  final String triggerWord;
  final String amountPattern;
  final String? descriptionPattern;
  final String? datePattern;
  final String? categoryId;
  final String? selectedAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExpenseTemplate(
      {required this.id,
      required this.sourceId,
      required this.sampleMessage,
      required this.triggerWord,
      required this.amountPattern,
      this.descriptionPattern,
      this.datePattern,
      this.categoryId,
      this.selectedAmount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['sample_message'] = Variable<String>(sampleMessage);
    map['trigger_word'] = Variable<String>(triggerWord);
    map['amount_pattern'] = Variable<String>(amountPattern);
    if (!nullToAbsent || descriptionPattern != null) {
      map['description_pattern'] = Variable<String>(descriptionPattern);
    }
    if (!nullToAbsent || datePattern != null) {
      map['date_pattern'] = Variable<String>(datePattern);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || selectedAmount != null) {
      map['selected_amount'] = Variable<String>(selectedAmount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExpenseTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseTemplatesCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      sampleMessage: Value(sampleMessage),
      triggerWord: Value(triggerWord),
      amountPattern: Value(amountPattern),
      descriptionPattern: descriptionPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionPattern),
      datePattern: datePattern == null && nullToAbsent
          ? const Value.absent()
          : Value(datePattern),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      selectedAmount: selectedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedAmount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExpenseTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseTemplate(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sampleMessage: serializer.fromJson<String>(json['sampleMessage']),
      triggerWord: serializer.fromJson<String>(json['triggerWord']),
      amountPattern: serializer.fromJson<String>(json['amountPattern']),
      descriptionPattern:
          serializer.fromJson<String?>(json['descriptionPattern']),
      datePattern: serializer.fromJson<String?>(json['datePattern']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      selectedAmount: serializer.fromJson<String?>(json['selectedAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'sampleMessage': serializer.toJson<String>(sampleMessage),
      'triggerWord': serializer.toJson<String>(triggerWord),
      'amountPattern': serializer.toJson<String>(amountPattern),
      'descriptionPattern': serializer.toJson<String?>(descriptionPattern),
      'datePattern': serializer.toJson<String?>(datePattern),
      'categoryId': serializer.toJson<String?>(categoryId),
      'selectedAmount': serializer.toJson<String?>(selectedAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExpenseTemplate copyWith(
          {String? id,
          String? sourceId,
          String? sampleMessage,
          String? triggerWord,
          String? amountPattern,
          Value<String?> descriptionPattern = const Value.absent(),
          Value<String?> datePattern = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          Value<String?> selectedAmount = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ExpenseTemplate(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        sampleMessage: sampleMessage ?? this.sampleMessage,
        triggerWord: triggerWord ?? this.triggerWord,
        amountPattern: amountPattern ?? this.amountPattern,
        descriptionPattern: descriptionPattern.present
            ? descriptionPattern.value
            : this.descriptionPattern,
        datePattern: datePattern.present ? datePattern.value : this.datePattern,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        selectedAmount:
            selectedAmount.present ? selectedAmount.value : this.selectedAmount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ExpenseTemplate copyWithCompanion(ExpenseTemplatesCompanion data) {
    return ExpenseTemplate(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sampleMessage: data.sampleMessage.present
          ? data.sampleMessage.value
          : this.sampleMessage,
      triggerWord:
          data.triggerWord.present ? data.triggerWord.value : this.triggerWord,
      amountPattern: data.amountPattern.present
          ? data.amountPattern.value
          : this.amountPattern,
      descriptionPattern: data.descriptionPattern.present
          ? data.descriptionPattern.value
          : this.descriptionPattern,
      datePattern:
          data.datePattern.present ? data.datePattern.value : this.datePattern,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      selectedAmount: data.selectedAmount.present
          ? data.selectedAmount.value
          : this.selectedAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseTemplate(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('sampleMessage: $sampleMessage, ')
          ..write('triggerWord: $triggerWord, ')
          ..write('amountPattern: $amountPattern, ')
          ..write('descriptionPattern: $descriptionPattern, ')
          ..write('datePattern: $datePattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('selectedAmount: $selectedAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sourceId,
      sampleMessage,
      triggerWord,
      amountPattern,
      descriptionPattern,
      datePattern,
      categoryId,
      selectedAmount,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseTemplate &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.sampleMessage == this.sampleMessage &&
          other.triggerWord == this.triggerWord &&
          other.amountPattern == this.amountPattern &&
          other.descriptionPattern == this.descriptionPattern &&
          other.datePattern == this.datePattern &&
          other.categoryId == this.categoryId &&
          other.selectedAmount == this.selectedAmount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpenseTemplatesCompanion extends UpdateCompanion<ExpenseTemplate> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> sampleMessage;
  final Value<String> triggerWord;
  final Value<String> amountPattern;
  final Value<String?> descriptionPattern;
  final Value<String?> datePattern;
  final Value<String?> categoryId;
  final Value<String?> selectedAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExpenseTemplatesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sampleMessage = const Value.absent(),
    this.triggerWord = const Value.absent(),
    this.amountPattern = const Value.absent(),
    this.descriptionPattern = const Value.absent(),
    this.datePattern = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.selectedAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseTemplatesCompanion.insert({
    required String id,
    required String sourceId,
    required String sampleMessage,
    required String triggerWord,
    required String amountPattern,
    this.descriptionPattern = const Value.absent(),
    this.datePattern = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.selectedAmount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceId = Value(sourceId),
        sampleMessage = Value(sampleMessage),
        triggerWord = Value(triggerWord),
        amountPattern = Value(amountPattern),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ExpenseTemplate> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? sampleMessage,
    Expression<String>? triggerWord,
    Expression<String>? amountPattern,
    Expression<String>? descriptionPattern,
    Expression<String>? datePattern,
    Expression<String>? categoryId,
    Expression<String>? selectedAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (sampleMessage != null) 'sample_message': sampleMessage,
      if (triggerWord != null) 'trigger_word': triggerWord,
      if (amountPattern != null) 'amount_pattern': amountPattern,
      if (descriptionPattern != null) 'description_pattern': descriptionPattern,
      if (datePattern != null) 'date_pattern': datePattern,
      if (categoryId != null) 'category_id': categoryId,
      if (selectedAmount != null) 'selected_amount': selectedAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceId,
      Value<String>? sampleMessage,
      Value<String>? triggerWord,
      Value<String>? amountPattern,
      Value<String?>? descriptionPattern,
      Value<String?>? datePattern,
      Value<String?>? categoryId,
      Value<String?>? selectedAmount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ExpenseTemplatesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      sampleMessage: sampleMessage ?? this.sampleMessage,
      triggerWord: triggerWord ?? this.triggerWord,
      amountPattern: amountPattern ?? this.amountPattern,
      descriptionPattern: descriptionPattern ?? this.descriptionPattern,
      datePattern: datePattern ?? this.datePattern,
      categoryId: categoryId ?? this.categoryId,
      selectedAmount: selectedAmount ?? this.selectedAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sampleMessage.present) {
      map['sample_message'] = Variable<String>(sampleMessage.value);
    }
    if (triggerWord.present) {
      map['trigger_word'] = Variable<String>(triggerWord.value);
    }
    if (amountPattern.present) {
      map['amount_pattern'] = Variable<String>(amountPattern.value);
    }
    if (descriptionPattern.present) {
      map['description_pattern'] = Variable<String>(descriptionPattern.value);
    }
    if (datePattern.present) {
      map['date_pattern'] = Variable<String>(datePattern.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (selectedAmount.present) {
      map['selected_amount'] = Variable<String>(selectedAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('sampleMessage: $sampleMessage, ')
          ..write('triggerWord: $triggerWord, ')
          ..write('amountPattern: $amountPattern, ')
          ..write('descriptionPattern: $descriptionPattern, ')
          ..write('datePattern: $datePattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('selectedAmount: $selectedAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _rolloverEnabledMeta =
      const VerificationMeta('rolloverEnabled');
  @override
  late final GeneratedColumn<bool> rolloverEnabled = GeneratedColumn<bool>(
      'rollover_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("rollover_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _rolloverAmountMeta =
      const VerificationMeta('rolloverAmount');
  @override
  late final GeneratedColumn<double> rolloverAmount = GeneratedColumn<double>(
      'rollover_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        amount,
        period,
        startDate,
        rolloverEnabled,
        rolloverAmount,
        isEnabled,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<Budget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('rollover_enabled')) {
      context.handle(
          _rolloverEnabledMeta,
          rolloverEnabled.isAcceptableOrUnknown(
              data['rollover_enabled']!, _rolloverEnabledMeta));
    }
    if (data.containsKey('rollover_amount')) {
      context.handle(
          _rolloverAmountMeta,
          rolloverAmount.isAcceptableOrUnknown(
              data['rollover_amount']!, _rolloverAmountMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      rolloverEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}rollover_enabled'])!,
      rolloverAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}rollover_amount'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String? categoryId;
  final double amount;
  final String period;
  final DateTime startDate;
  final bool rolloverEnabled;
  final double rolloverAmount;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Budget(
      {required this.id,
      this.categoryId,
      required this.amount,
      required this.period,
      required this.startDate,
      required this.rolloverEnabled,
      required this.rolloverAmount,
      required this.isEnabled,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['amount'] = Variable<double>(amount);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['rollover_enabled'] = Variable<bool>(rolloverEnabled);
    map['rollover_amount'] = Variable<double>(rolloverAmount);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      period: Value(period),
      startDate: Value(startDate),
      rolloverEnabled: Value(rolloverEnabled),
      rolloverAmount: Value(rolloverAmount),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      rolloverEnabled: serializer.fromJson<bool>(json['rolloverEnabled']),
      rolloverAmount: serializer.fromJson<double>(json['rolloverAmount']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'rolloverEnabled': serializer.toJson<bool>(rolloverEnabled),
      'rolloverAmount': serializer.toJson<double>(rolloverAmount),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Budget copyWith(
          {String? id,
          Value<String?> categoryId = const Value.absent(),
          double? amount,
          String? period,
          DateTime? startDate,
          bool? rolloverEnabled,
          double? rolloverAmount,
          bool? isEnabled,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Budget(
        id: id ?? this.id,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        amount: amount ?? this.amount,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
        rolloverAmount: rolloverAmount ?? this.rolloverAmount,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      rolloverEnabled: data.rolloverEnabled.present
          ? data.rolloverEnabled.value
          : this.rolloverEnabled,
      rolloverAmount: data.rolloverAmount.present
          ? data.rolloverAmount.value
          : this.rolloverAmount,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('rolloverAmount: $rolloverAmount, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, amount, period, startDate,
      rolloverEnabled, rolloverAmount, isEnabled, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.rolloverEnabled == this.rolloverEnabled &&
          other.rolloverAmount == this.rolloverAmount &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String?> categoryId;
  final Value<double> amount;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<bool> rolloverEnabled;
  final Value<double> rolloverAmount;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.rolloverEnabled = const Value.absent(),
    this.rolloverAmount = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    this.categoryId = const Value.absent(),
    required double amount,
    required String period,
    required DateTime startDate,
    this.rolloverEnabled = const Value.absent(),
    this.rolloverAmount = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        period = Value(period),
        startDate = Value(startDate);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<bool>? rolloverEnabled,
    Expression<double>? rolloverAmount,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (rolloverEnabled != null) 'rollover_enabled': rolloverEnabled,
      if (rolloverAmount != null) 'rollover_amount': rolloverAmount,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? categoryId,
      Value<double>? amount,
      Value<String>? period,
      Value<DateTime>? startDate,
      Value<bool>? rolloverEnabled,
      Value<double>? rolloverAmount,
      Value<bool>? isEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (rolloverEnabled.present) {
      map['rollover_enabled'] = Variable<bool>(rolloverEnabled.value);
    }
    if (rolloverAmount.present) {
      map['rollover_amount'] = Variable<double>(rolloverAmount.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('rolloverAmount: $rolloverAmount, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextOccurrenceMeta =
      const VerificationMeta('nextOccurrence');
  @override
  late final GeneratedColumn<DateTime> nextOccurrence =
      GeneratedColumn<DateTime>('next_occurrence', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _autoCreateExpenseMeta =
      const VerificationMeta('autoCreateExpense');
  @override
  late final GeneratedColumn<bool> autoCreateExpense = GeneratedColumn<bool>(
      'auto_create_expense', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_create_expense" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _dayOfMonthMeta =
      const VerificationMeta('dayOfMonth');
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
      'day_of_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        description,
        amount,
        categoryId,
        frequency,
        startDate,
        endDate,
        nextOccurrence,
        isActive,
        autoCreateExpense,
        dayOfMonth,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('next_occurrence')) {
      context.handle(
          _nextOccurrenceMeta,
          nextOccurrence.isAcceptableOrUnknown(
              data['next_occurrence']!, _nextOccurrenceMeta));
    } else if (isInserting) {
      context.missing(_nextOccurrenceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('auto_create_expense')) {
      context.handle(
          _autoCreateExpenseMeta,
          autoCreateExpense.isAcceptableOrUnknown(
              data['auto_create_expense']!, _autoCreateExpenseMeta));
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
          _dayOfMonthMeta,
          dayOfMonth.isAcceptableOrUnknown(
              data['day_of_month']!, _dayOfMonthMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      nextOccurrence: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_occurrence'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      autoCreateExpense: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_create_expense'])!,
      dayOfMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_month']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }
}

class RecurringTransaction extends DataClass
    implements Insertable<RecurringTransaction> {
  final String id;
  final String description;
  final double amount;
  final String? categoryId;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextOccurrence;
  final bool isActive;
  final bool autoCreateExpense;
  final int? dayOfMonth;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecurringTransaction(
      {required this.id,
      required this.description,
      required this.amount,
      this.categoryId,
      required this.frequency,
      required this.startDate,
      this.endDate,
      required this.nextOccurrence,
      required this.isActive,
      required this.autoCreateExpense,
      this.dayOfMonth,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['frequency'] = Variable<String>(frequency);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['next_occurrence'] = Variable<DateTime>(nextOccurrence);
    map['is_active'] = Variable<bool>(isActive);
    map['auto_create_expense'] = Variable<bool>(autoCreateExpense);
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      description: Value(description),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      frequency: Value(frequency),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      nextOccurrence: Value(nextOccurrence),
      isActive: Value(isActive),
      autoCreateExpense: Value(autoCreateExpense),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransaction(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      nextOccurrence: serializer.fromJson<DateTime>(json['nextOccurrence']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      autoCreateExpense: serializer.fromJson<bool>(json['autoCreateExpense']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String?>(categoryId),
      'frequency': serializer.toJson<String>(frequency),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'nextOccurrence': serializer.toJson<DateTime>(nextOccurrence),
      'isActive': serializer.toJson<bool>(isActive),
      'autoCreateExpense': serializer.toJson<bool>(autoCreateExpense),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecurringTransaction copyWith(
          {String? id,
          String? description,
          double? amount,
          Value<String?> categoryId = const Value.absent(),
          String? frequency,
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          DateTime? nextOccurrence,
          bool? isActive,
          bool? autoCreateExpense,
          Value<int?> dayOfMonth = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      RecurringTransaction(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        frequency: frequency ?? this.frequency,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        nextOccurrence: nextOccurrence ?? this.nextOccurrence,
        isActive: isActive ?? this.isActive,
        autoCreateExpense: autoCreateExpense ?? this.autoCreateExpense,
        dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RecurringTransaction copyWithCompanion(RecurringTransactionsCompanion data) {
    return RecurringTransaction(
      id: data.id.present ? data.id.value : this.id,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      nextOccurrence: data.nextOccurrence.present
          ? data.nextOccurrence.value
          : this.nextOccurrence,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      autoCreateExpense: data.autoCreateExpense.present
          ? data.autoCreateExpense.value
          : this.autoCreateExpense,
      dayOfMonth:
          data.dayOfMonth.present ? data.dayOfMonth.value : this.dayOfMonth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransaction(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextOccurrence: $nextOccurrence, ')
          ..write('isActive: $isActive, ')
          ..write('autoCreateExpense: $autoCreateExpense, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      description,
      amount,
      categoryId,
      frequency,
      startDate,
      endDate,
      nextOccurrence,
      isActive,
      autoCreateExpense,
      dayOfMonth,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransaction &&
          other.id == this.id &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.frequency == this.frequency &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.nextOccurrence == this.nextOccurrence &&
          other.isActive == this.isActive &&
          other.autoCreateExpense == this.autoCreateExpense &&
          other.dayOfMonth == this.dayOfMonth &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransaction> {
  final Value<String> id;
  final Value<String> description;
  final Value<double> amount;
  final Value<String?> categoryId;
  final Value<String> frequency;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> nextOccurrence;
  final Value<bool> isActive;
  final Value<bool> autoCreateExpense;
  final Value<int?> dayOfMonth;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.nextOccurrence = const Value.absent(),
    this.isActive = const Value.absent(),
    this.autoCreateExpense = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    required String id,
    required String description,
    required double amount,
    this.categoryId = const Value.absent(),
    required String frequency,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required DateTime nextOccurrence,
    this.isActive = const Value.absent(),
    this.autoCreateExpense = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        description = Value(description),
        amount = Value(amount),
        frequency = Value(frequency),
        startDate = Value(startDate),
        nextOccurrence = Value(nextOccurrence);
  static Insertable<RecurringTransaction> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<String>? frequency,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? nextOccurrence,
    Expression<bool>? isActive,
    Expression<bool>? autoCreateExpense,
    Expression<int>? dayOfMonth,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (frequency != null) 'frequency': frequency,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (nextOccurrence != null) 'next_occurrence': nextOccurrence,
      if (isActive != null) 'is_active': isActive,
      if (autoCreateExpense != null) 'auto_create_expense': autoCreateExpense,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? description,
      Value<double>? amount,
      Value<String?>? categoryId,
      Value<String>? frequency,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<DateTime>? nextOccurrence,
      Value<bool>? isActive,
      Value<bool>? autoCreateExpense,
      Value<int?>? dayOfMonth,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      isActive: isActive ?? this.isActive,
      autoCreateExpense: autoCreateExpense ?? this.autoCreateExpense,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (nextOccurrence.present) {
      map['next_occurrence'] = Variable<DateTime>(nextOccurrence.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (autoCreateExpense.present) {
      map['auto_create_expense'] = Variable<bool>(autoCreateExpense.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextOccurrence: $nextOccurrence, ')
          ..write('isActive: $isActive, ')
          ..write('autoCreateExpense: $autoCreateExpense, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseFtsTableTable extends ExpenseFtsTable
    with TableInfo<$ExpenseFtsTableTable, ExpenseFts> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseFtsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _expenseIdMeta =
      const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<int> expenseId = GeneratedColumn<int>(
      'expense_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [expenseId, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_fts';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseFts> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta,
          expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ExpenseFts map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseFts(
      expenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expense_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $ExpenseFtsTableTable createAlias(String alias) {
    return $ExpenseFtsTableTable(attachedDatabase, alias);
  }
}

class ExpenseFts extends DataClass implements Insertable<ExpenseFts> {
  final int expenseId;
  final String description;
  const ExpenseFts({required this.expenseId, required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['expense_id'] = Variable<int>(expenseId);
    map['description'] = Variable<String>(description);
    return map;
  }

  ExpenseFtsTableCompanion toCompanion(bool nullToAbsent) {
    return ExpenseFtsTableCompanion(
      expenseId: Value(expenseId),
      description: Value(description),
    );
  }

  factory ExpenseFts.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseFts(
      expenseId: serializer.fromJson<int>(json['expenseId']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'expenseId': serializer.toJson<int>(expenseId),
      'description': serializer.toJson<String>(description),
    };
  }

  ExpenseFts copyWith({int? expenseId, String? description}) => ExpenseFts(
        expenseId: expenseId ?? this.expenseId,
        description: description ?? this.description,
      );
  ExpenseFts copyWithCompanion(ExpenseFtsTableCompanion data) {
    return ExpenseFts(
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseFts(')
          ..write('expenseId: $expenseId, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(expenseId, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseFts &&
          other.expenseId == this.expenseId &&
          other.description == this.description);
}

class ExpenseFtsTableCompanion extends UpdateCompanion<ExpenseFts> {
  final Value<int> expenseId;
  final Value<String> description;
  final Value<int> rowid;
  const ExpenseFtsTableCompanion({
    this.expenseId = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseFtsTableCompanion.insert({
    required int expenseId,
    required String description,
    this.rowid = const Value.absent(),
  })  : expenseId = Value(expenseId),
        description = Value(description);
  static Insertable<ExpenseFts> custom({
    Expression<int>? expenseId,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (expenseId != null) 'expense_id': expenseId,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseFtsTableCompanion copyWith(
      {Value<int>? expenseId, Value<String>? description, Value<int>? rowid}) {
    return ExpenseFtsTableCompanion(
      expenseId: expenseId ?? this.expenseId,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (expenseId.present) {
      map['expense_id'] = Variable<int>(expenseId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseFtsTableCompanion(')
          ..write('expenseId: $expenseId, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecordsTable records = $RecordsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PendingRecurringTable pendingRecurring =
      $PendingRecurringTable(this);
  late final $ParsingRulesTable parsingRules = $ParsingRulesTable(this);
  late final $MessageSourcesTable messageSources = $MessageSourcesTable(this);
  late final $ExpenseTemplatesTable expenseTemplates =
      $ExpenseTemplatesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $ExpenseFtsTableTable expenseFtsTable =
      $ExpenseFtsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        records,
        categories,
        pendingRecurring,
        parsingRules,
        messageSources,
        expenseTemplates,
        budgets,
        recurringTransactions,
        expenseFtsTable
      ];
}

typedef $$RecordsTableCreateCompanionBuilder = RecordsCompanion Function({
  Value<int> id,
  required double amount,
  required String description,
  required DateTime date,
  Value<int?> categoryId,
  Value<String> source,
  Value<String?> sourceId,
  required String recordType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$RecordsTableUpdateCompanionBuilder = RecordsCompanion Function({
  Value<int> id,
  Value<double> amount,
  Value<String> description,
  Value<DateTime> date,
  Value<int?> categoryId,
  Value<String> source,
  Value<String?> sourceId,
  Value<String> recordType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$RecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecordsTable,
    Record,
    $$RecordsTableFilterComposer,
    $$RecordsTableOrderingComposer,
    $$RecordsTableCreateCompanionBuilder,
    $$RecordsTableUpdateCompanionBuilder> {
  $$RecordsTableTableManager(_$AppDatabase db, $RecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RecordsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RecordsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<String> recordType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              RecordsCompanion(
            id: id,
            amount: amount,
            description: description,
            date: date,
            categoryId: categoryId,
            source: source,
            sourceId: sourceId,
            recordType: recordType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double amount,
            required String description,
            required DateTime date,
            Value<int?> categoryId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            required String recordType,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              RecordsCompanion.insert(
            id: id,
            amount: amount,
            description: description,
            date: date,
            categoryId: categoryId,
            source: source,
            sourceId: sourceId,
            recordType: recordType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        ));
}

class $$RecordsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recordType => $state.composableBuilder(
      column: $state.table.recordType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$RecordsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sourceId => $state.composableBuilder(
      column: $state.table.sourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recordType => $state.composableBuilder(
      column: $state.table.recordType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  Value<String> emoji,
  Value<String> color,
  Value<bool> isDefault,
  Value<String> categoryType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> emoji,
  Value<String> color,
  Value<bool> isDefault,
  Value<String> categoryType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<String> categoryType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            isDefault: isDefault,
            categoryType: categoryType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> emoji = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<String> categoryType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            isDefault: isDefault,
            categoryType: categoryType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        ));
}

class $$CategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get categoryType => $state.composableBuilder(
      column: $state.table.categoryType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get categoryType => $state.composableBuilder(
      column: $state.table.categoryType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PendingRecurringTableCreateCompanionBuilder
    = PendingRecurringCompanion Function({
  Value<int> id,
  required String recurringId,
  required DateTime dueDate,
  required double amount,
  required String description,
  Value<String?> categoryId,
  Value<DateTime> createdAt,
});
typedef $$PendingRecurringTableUpdateCompanionBuilder
    = PendingRecurringCompanion Function({
  Value<int> id,
  Value<String> recurringId,
  Value<DateTime> dueDate,
  Value<double> amount,
  Value<String> description,
  Value<String?> categoryId,
  Value<DateTime> createdAt,
});

class $$PendingRecurringTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingRecurringTable,
    PendingRecurringData,
    $$PendingRecurringTableFilterComposer,
    $$PendingRecurringTableOrderingComposer,
    $$PendingRecurringTableCreateCompanionBuilder,
    $$PendingRecurringTableUpdateCompanionBuilder> {
  $$PendingRecurringTableTableManager(
      _$AppDatabase db, $PendingRecurringTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PendingRecurringTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PendingRecurringTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> recurringId = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingRecurringCompanion(
            id: id,
            recurringId: recurringId,
            dueDate: dueDate,
            amount: amount,
            description: description,
            categoryId: categoryId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String recurringId,
            required DateTime dueDate,
            required double amount,
            required String description,
            Value<String?> categoryId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingRecurringCompanion.insert(
            id: id,
            recurringId: recurringId,
            dueDate: dueDate,
            amount: amount,
            description: description,
            categoryId: categoryId,
            createdAt: createdAt,
          ),
        ));
}

class $$PendingRecurringTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PendingRecurringTable> {
  $$PendingRecurringTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recurringId => $state.composableBuilder(
      column: $state.table.recurringId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PendingRecurringTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PendingRecurringTable> {
  $$PendingRecurringTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recurringId => $state.composableBuilder(
      column: $state.table.recurringId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ParsingRulesTableCreateCompanionBuilder = ParsingRulesCompanion
    Function({
  required String id,
  required String name,
  required String triggerWords,
  required String amountPattern,
  Value<String?> datePattern,
  Value<String?> categoryId,
  required String sourceType,
  Value<bool> isEnabled,
  Value<int> priority,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ParsingRulesTableUpdateCompanionBuilder = ParsingRulesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> triggerWords,
  Value<String> amountPattern,
  Value<String?> datePattern,
  Value<String?> categoryId,
  Value<String> sourceType,
  Value<bool> isEnabled,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ParsingRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParsingRulesTable,
    ParsingRule,
    $$ParsingRulesTableFilterComposer,
    $$ParsingRulesTableOrderingComposer,
    $$ParsingRulesTableCreateCompanionBuilder,
    $$ParsingRulesTableUpdateCompanionBuilder> {
  $$ParsingRulesTableTableManager(_$AppDatabase db, $ParsingRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ParsingRulesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ParsingRulesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> triggerWords = const Value.absent(),
            Value<String> amountPattern = const Value.absent(),
            Value<String?> datePattern = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ParsingRulesCompanion(
            id: id,
            name: name,
            triggerWords: triggerWords,
            amountPattern: amountPattern,
            datePattern: datePattern,
            categoryId: categoryId,
            sourceType: sourceType,
            isEnabled: isEnabled,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String triggerWords,
            required String amountPattern,
            Value<String?> datePattern = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            required String sourceType,
            Value<bool> isEnabled = const Value.absent(),
            Value<int> priority = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ParsingRulesCompanion.insert(
            id: id,
            name: name,
            triggerWords: triggerWords,
            amountPattern: amountPattern,
            datePattern: datePattern,
            categoryId: categoryId,
            sourceType: sourceType,
            isEnabled: isEnabled,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$ParsingRulesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ParsingRulesTable> {
  $$ParsingRulesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get triggerWords => $state.composableBuilder(
      column: $state.table.triggerWords,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get amountPattern => $state.composableBuilder(
      column: $state.table.amountPattern,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get datePattern => $state.composableBuilder(
      column: $state.table.datePattern,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sourceType => $state.composableBuilder(
      column: $state.table.sourceType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isEnabled => $state.composableBuilder(
      column: $state.table.isEnabled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get priority => $state.composableBuilder(
      column: $state.table.priority,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ParsingRulesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ParsingRulesTable> {
  $$ParsingRulesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get triggerWords => $state.composableBuilder(
      column: $state.table.triggerWords,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get amountPattern => $state.composableBuilder(
      column: $state.table.amountPattern,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get datePattern => $state.composableBuilder(
      column: $state.table.datePattern,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sourceType => $state.composableBuilder(
      column: $state.table.sourceType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isEnabled => $state.composableBuilder(
      column: $state.table.isEnabled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get priority => $state.composableBuilder(
      column: $state.table.priority,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MessageSourcesTableCreateCompanionBuilder = MessageSourcesCompanion
    Function({
  required String id,
  required String contactId,
  required String contactName,
  Value<bool> isMonitored,
  Value<int> autoCreateOption,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MessageSourcesTableUpdateCompanionBuilder = MessageSourcesCompanion
    Function({
  Value<String> id,
  Value<String> contactId,
  Value<String> contactName,
  Value<bool> isMonitored,
  Value<int> autoCreateOption,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MessageSourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessageSourcesTable,
    MessageSource,
    $$MessageSourcesTableFilterComposer,
    $$MessageSourcesTableOrderingComposer,
    $$MessageSourcesTableCreateCompanionBuilder,
    $$MessageSourcesTableUpdateCompanionBuilder> {
  $$MessageSourcesTableTableManager(
      _$AppDatabase db, $MessageSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MessageSourcesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MessageSourcesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> contactId = const Value.absent(),
            Value<String> contactName = const Value.absent(),
            Value<bool> isMonitored = const Value.absent(),
            Value<int> autoCreateOption = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageSourcesCompanion(
            id: id,
            contactId: contactId,
            contactName: contactName,
            isMonitored: isMonitored,
            autoCreateOption: autoCreateOption,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String contactId,
            required String contactName,
            Value<bool> isMonitored = const Value.absent(),
            Value<int> autoCreateOption = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageSourcesCompanion.insert(
            id: id,
            contactId: contactId,
            contactName: contactName,
            isMonitored: isMonitored,
            autoCreateOption: autoCreateOption,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$MessageSourcesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MessageSourcesTable> {
  $$MessageSourcesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get contactId => $state.composableBuilder(
      column: $state.table.contactId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get contactName => $state.composableBuilder(
      column: $state.table.contactName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isMonitored => $state.composableBuilder(
      column: $state.table.isMonitored,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get autoCreateOption => $state.composableBuilder(
      column: $state.table.autoCreateOption,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter expenseTemplatesRefs(
      ComposableFilter Function($$ExpenseTemplatesTableFilterComposer f) f) {
    final $$ExpenseTemplatesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.expenseTemplates,
            getReferencedColumn: (t) => t.sourceId,
            builder: (joinBuilder, parentComposers) =>
                $$ExpenseTemplatesTableFilterComposer(ComposerState($state.db,
                    $state.db.expenseTemplates, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$MessageSourcesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MessageSourcesTable> {
  $$MessageSourcesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contactId => $state.composableBuilder(
      column: $state.table.contactId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contactName => $state.composableBuilder(
      column: $state.table.contactName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isMonitored => $state.composableBuilder(
      column: $state.table.isMonitored,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get autoCreateOption => $state.composableBuilder(
      column: $state.table.autoCreateOption,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ExpenseTemplatesTableCreateCompanionBuilder
    = ExpenseTemplatesCompanion Function({
  required String id,
  required String sourceId,
  required String sampleMessage,
  required String triggerWord,
  required String amountPattern,
  Value<String?> descriptionPattern,
  Value<String?> datePattern,
  Value<String?> categoryId,
  Value<String?> selectedAmount,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ExpenseTemplatesTableUpdateCompanionBuilder
    = ExpenseTemplatesCompanion Function({
  Value<String> id,
  Value<String> sourceId,
  Value<String> sampleMessage,
  Value<String> triggerWord,
  Value<String> amountPattern,
  Value<String?> descriptionPattern,
  Value<String?> datePattern,
  Value<String?> categoryId,
  Value<String?> selectedAmount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ExpenseTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseTemplatesTable,
    ExpenseTemplate,
    $$ExpenseTemplatesTableFilterComposer,
    $$ExpenseTemplatesTableOrderingComposer,
    $$ExpenseTemplatesTableCreateCompanionBuilder,
    $$ExpenseTemplatesTableUpdateCompanionBuilder> {
  $$ExpenseTemplatesTableTableManager(
      _$AppDatabase db, $ExpenseTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ExpenseTemplatesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ExpenseTemplatesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> sampleMessage = const Value.absent(),
            Value<String> triggerWord = const Value.absent(),
            Value<String> amountPattern = const Value.absent(),
            Value<String?> descriptionPattern = const Value.absent(),
            Value<String?> datePattern = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> selectedAmount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseTemplatesCompanion(
            id: id,
            sourceId: sourceId,
            sampleMessage: sampleMessage,
            triggerWord: triggerWord,
            amountPattern: amountPattern,
            descriptionPattern: descriptionPattern,
            datePattern: datePattern,
            categoryId: categoryId,
            selectedAmount: selectedAmount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceId,
            required String sampleMessage,
            required String triggerWord,
            required String amountPattern,
            Value<String?> descriptionPattern = const Value.absent(),
            Value<String?> datePattern = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> selectedAmount = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseTemplatesCompanion.insert(
            id: id,
            sourceId: sourceId,
            sampleMessage: sampleMessage,
            triggerWord: triggerWord,
            amountPattern: amountPattern,
            descriptionPattern: descriptionPattern,
            datePattern: datePattern,
            categoryId: categoryId,
            selectedAmount: selectedAmount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$ExpenseTemplatesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ExpenseTemplatesTable> {
  $$ExpenseTemplatesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sampleMessage => $state.composableBuilder(
      column: $state.table.sampleMessage,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get triggerWord => $state.composableBuilder(
      column: $state.table.triggerWord,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get amountPattern => $state.composableBuilder(
      column: $state.table.amountPattern,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get descriptionPattern => $state.composableBuilder(
      column: $state.table.descriptionPattern,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get datePattern => $state.composableBuilder(
      column: $state.table.datePattern,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get selectedAmount => $state.composableBuilder(
      column: $state.table.selectedAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$MessageSourcesTableFilterComposer get sourceId {
    final $$MessageSourcesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $state.db.messageSources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MessageSourcesTableFilterComposer(ComposerState($state.db,
                $state.db.messageSources, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ExpenseTemplatesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ExpenseTemplatesTable> {
  $$ExpenseTemplatesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sampleMessage => $state.composableBuilder(
      column: $state.table.sampleMessage,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get triggerWord => $state.composableBuilder(
      column: $state.table.triggerWord,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get amountPattern => $state.composableBuilder(
      column: $state.table.amountPattern,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get descriptionPattern => $state.composableBuilder(
      column: $state.table.descriptionPattern,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get datePattern => $state.composableBuilder(
      column: $state.table.datePattern,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get selectedAmount => $state.composableBuilder(
      column: $state.table.selectedAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$MessageSourcesTableOrderingComposer get sourceId {
    final $$MessageSourcesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sourceId,
            referencedTable: $state.db.messageSources,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$MessageSourcesTableOrderingComposer(ComposerState($state.db,
                    $state.db.messageSources, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  Value<String?> categoryId,
  required double amount,
  required String period,
  required DateTime startDate,
  Value<bool> rolloverEnabled,
  Value<double> rolloverAmount,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String?> categoryId,
  Value<double> amount,
  Value<String> period,
  Value<DateTime> startDate,
  Value<bool> rolloverEnabled,
  Value<double> rolloverAmount,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BudgetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BudgetsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<bool> rolloverEnabled = const Value.absent(),
            Value<double> rolloverAmount = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            categoryId: categoryId,
            amount: amount,
            period: period,
            startDate: startDate,
            rolloverEnabled: rolloverEnabled,
            rolloverAmount: rolloverAmount,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> categoryId = const Value.absent(),
            required double amount,
            required String period,
            required DateTime startDate,
            Value<bool> rolloverEnabled = const Value.absent(),
            Value<double> rolloverAmount = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            amount: amount,
            period: period,
            startDate: startDate,
            rolloverEnabled: rolloverEnabled,
            rolloverAmount: rolloverAmount,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$BudgetsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get rolloverEnabled => $state.composableBuilder(
      column: $state.table.rolloverEnabled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get rolloverAmount => $state.composableBuilder(
      column: $state.table.rolloverAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isEnabled => $state.composableBuilder(
      column: $state.table.isEnabled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BudgetsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get rolloverEnabled => $state.composableBuilder(
      column: $state.table.rolloverEnabled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get rolloverAmount => $state.composableBuilder(
      column: $state.table.rolloverAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isEnabled => $state.composableBuilder(
      column: $state.table.isEnabled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RecurringTransactionsTableCreateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  required String id,
  required String description,
  required double amount,
  Value<String?> categoryId,
  required String frequency,
  required DateTime startDate,
  Value<DateTime?> endDate,
  required DateTime nextOccurrence,
  Value<bool> isActive,
  Value<bool> autoCreateExpense,
  Value<int?> dayOfMonth,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$RecurringTransactionsTableUpdateCompanionBuilder
    = RecurringTransactionsCompanion Function({
  Value<String> id,
  Value<String> description,
  Value<double> amount,
  Value<String?> categoryId,
  Value<String> frequency,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> nextOccurrence,
  Value<bool> isActive,
  Value<bool> autoCreateExpense,
  Value<int?> dayOfMonth,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RecurringTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTransactionsTable,
    RecurringTransaction,
    $$RecurringTransactionsTableFilterComposer,
    $$RecurringTransactionsTableOrderingComposer,
    $$RecurringTransactionsTableCreateCompanionBuilder,
    $$RecurringTransactionsTableUpdateCompanionBuilder> {
  $$RecurringTransactionsTableTableManager(
      _$AppDatabase db, $RecurringTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$RecurringTransactionsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$RecurringTransactionsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> nextOccurrence = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> autoCreateExpense = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion(
            id: id,
            description: description,
            amount: amount,
            categoryId: categoryId,
            frequency: frequency,
            startDate: startDate,
            endDate: endDate,
            nextOccurrence: nextOccurrence,
            isActive: isActive,
            autoCreateExpense: autoCreateExpense,
            dayOfMonth: dayOfMonth,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String description,
            required double amount,
            Value<String?> categoryId = const Value.absent(),
            required String frequency,
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            required DateTime nextOccurrence,
            Value<bool> isActive = const Value.absent(),
            Value<bool> autoCreateExpense = const Value.absent(),
            Value<int?> dayOfMonth = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTransactionsCompanion.insert(
            id: id,
            description: description,
            amount: amount,
            categoryId: categoryId,
            frequency: frequency,
            startDate: startDate,
            endDate: endDate,
            nextOccurrence: nextOccurrence,
            isActive: isActive,
            autoCreateExpense: autoCreateExpense,
            dayOfMonth: dayOfMonth,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$RecurringTransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get nextOccurrence => $state.composableBuilder(
      column: $state.table.nextOccurrence,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get autoCreateExpense => $state.composableBuilder(
      column: $state.table.autoCreateExpense,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dayOfMonth => $state.composableBuilder(
      column: $state.table.dayOfMonth,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$RecurringTransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get nextOccurrence => $state.composableBuilder(
      column: $state.table.nextOccurrence,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get autoCreateExpense => $state.composableBuilder(
      column: $state.table.autoCreateExpense,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dayOfMonth => $state.composableBuilder(
      column: $state.table.dayOfMonth,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ExpenseFtsTableTableCreateCompanionBuilder = ExpenseFtsTableCompanion
    Function({
  required int expenseId,
  required String description,
  Value<int> rowid,
});
typedef $$ExpenseFtsTableTableUpdateCompanionBuilder = ExpenseFtsTableCompanion
    Function({
  Value<int> expenseId,
  Value<String> description,
  Value<int> rowid,
});

class $$ExpenseFtsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseFtsTableTable,
    ExpenseFts,
    $$ExpenseFtsTableTableFilterComposer,
    $$ExpenseFtsTableTableOrderingComposer,
    $$ExpenseFtsTableTableCreateCompanionBuilder,
    $$ExpenseFtsTableTableUpdateCompanionBuilder> {
  $$ExpenseFtsTableTableTableManager(
      _$AppDatabase db, $ExpenseFtsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ExpenseFtsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ExpenseFtsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> expenseId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseFtsTableCompanion(
            expenseId: expenseId,
            description: description,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int expenseId,
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseFtsTableCompanion.insert(
            expenseId: expenseId,
            description: description,
            rowid: rowid,
          ),
        ));
}

class $$ExpenseFtsTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ExpenseFtsTableTable> {
  $$ExpenseFtsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get expenseId => $state.composableBuilder(
      column: $state.table.expenseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ExpenseFtsTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ExpenseFtsTableTable> {
  $$ExpenseFtsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get expenseId => $state.composableBuilder(
      column: $state.table.expenseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecordsTableTableManager get records =>
      $$RecordsTableTableManager(_db, _db.records);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PendingRecurringTableTableManager get pendingRecurring =>
      $$PendingRecurringTableTableManager(_db, _db.pendingRecurring);
  $$ParsingRulesTableTableManager get parsingRules =>
      $$ParsingRulesTableTableManager(_db, _db.parsingRules);
  $$MessageSourcesTableTableManager get messageSources =>
      $$MessageSourcesTableTableManager(_db, _db.messageSources);
  $$ExpenseTemplatesTableTableManager get expenseTemplates =>
      $$ExpenseTemplatesTableTableManager(_db, _db.expenseTemplates);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$ExpenseFtsTableTableTableManager get expenseFtsTable =>
      $$ExpenseFtsTableTableTableManager(_db, _db.expenseFtsTable);
}
