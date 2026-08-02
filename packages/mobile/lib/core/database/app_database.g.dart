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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(ExpenseSource.manual.name),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    description,
    date,
    categoryId,
    budgetId,
    source,
    sourceId,
    recordType,
    userId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'records';
  @override
  VerificationContext validateIntegrity(
    Insertable<Record> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Record map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Record(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RecordsTable createAlias(String alias) {
    return $RecordsTable(attachedDatabase, alias);
  }
}

class Record extends DataClass implements Insertable<Record> {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String? categoryId;
  final String? budgetId;
  final String source;
  final String? sourceId;
  final String recordType;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Record({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    this.categoryId,
    this.budgetId,
    required this.source,
    this.sourceId,
    required this.recordType,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || budgetId != null) {
      map['budget_id'] = Variable<String>(budgetId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['record_type'] = Variable<String>(recordType);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
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
      budgetId: budgetId == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetId),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      recordType: Value(recordType),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Record.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Record(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      budgetId: serializer.fromJson<String?>(json['budgetId']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      userId: serializer.fromJson<int?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'date': serializer.toJson<DateTime>(date),
      'categoryId': serializer.toJson<String?>(categoryId),
      'budgetId': serializer.toJson<String?>(budgetId),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'recordType': serializer.toJson<String>(recordType),
      'userId': serializer.toJson<int?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Record copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> budgetId = const Value.absent(),
    String? source,
    Value<String?> sourceId = const Value.absent(),
    String? recordType,
    Value<int?> userId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Record(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    date: date ?? this.date,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    budgetId: budgetId.present ? budgetId.value : this.budgetId,
    source: source ?? this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    recordType: recordType ?? this.recordType,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Record copyWithCompanion(RecordsCompanion data) {
    return Record(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      date: data.date.present ? data.date.value : this.date,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      userId: data.userId.present ? data.userId.value : this.userId,
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
          ..write('budgetId: $budgetId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('recordType: $recordType, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    description,
    date,
    categoryId,
    budgetId,
    source,
    sourceId,
    recordType,
    userId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Record &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.categoryId == this.categoryId &&
          other.budgetId == this.budgetId &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.recordType == this.recordType &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecordsCompanion extends UpdateCompanion<Record> {
  final Value<String> id;
  final Value<double> amount;
  final Value<String> description;
  final Value<DateTime> date;
  final Value<String?> categoryId;
  final Value<String?> budgetId;
  final Value<String> source;
  final Value<String?> sourceId;
  final Value<String> recordType;
  final Value<int?> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecordsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecordsCompanion.insert({
    required String id,
    required double amount,
    required String description,
    required DateTime date,
    this.categoryId = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String recordType,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       description = Value(description),
       date = Value(date),
       recordType = Value(recordType);
  static Insertable<Record> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<String>? categoryId,
    Expression<String>? budgetId,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? recordType,
    Expression<int>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (categoryId != null) 'category_id': categoryId,
      if (budgetId != null) 'budget_id': budgetId,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (recordType != null) 'record_type': recordType,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecordsCompanion copyWith({
    Value<String>? id,
    Value<double>? amount,
    Value<String>? description,
    Value<DateTime>? date,
    Value<String?>? categoryId,
    Value<String?>? budgetId,
    Value<String>? source,
    Value<String?>? sourceId,
    Value<String>? recordType,
    Value<int?>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecordsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      recordType: recordType ?? this.recordType,
      userId: userId ?? this.userId,
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
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
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
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
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
    return (StringBuffer('RecordsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('budgetId: $budgetId, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('recordType: $recordType, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('package'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#2196F3'),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _categoryTypeMeta = const VerificationMeta(
    'categoryType',
  );
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
    'category_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RecordType.expense.dbValue),
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    color,
    isDefault,
    categoryType,
    usageCount,
    userId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('category_type')) {
      context.handle(
        _categoryTypeMeta,
        categoryType.isAcceptableOrUnknown(
          data['category_type']!,
          _categoryTypeMeta,
        ),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      categoryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_type'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String emoji;
  final String color;
  final bool isDefault;
  final String categoryType;
  final int usageCount;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.isDefault,
    required this.categoryType,
    required this.usageCount,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<String>(color);
    map['is_default'] = Variable<bool>(isDefault);
    map['category_type'] = Variable<String>(categoryType);
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
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
      usageCount: Value(usageCount),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<String>(json['color']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      categoryType: serializer.fromJson<String>(json['categoryType']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      userId: serializer.fromJson<int?>(json['userId']),
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
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<String>(color),
      'isDefault': serializer.toJson<bool>(isDefault),
      'categoryType': serializer.toJson<String>(categoryType),
      'usageCount': serializer.toJson<int>(usageCount),
      'userId': serializer.toJson<int?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? emoji,
    String? color,
    bool? isDefault,
    String? categoryType,
    int? usageCount,
    Value<int?> userId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    color: color ?? this.color,
    isDefault: isDefault ?? this.isDefault,
    categoryType: categoryType ?? this.categoryType,
    usageCount: usageCount ?? this.usageCount,
    userId: userId.present ? userId.value : this.userId,
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
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      userId: data.userId.present ? data.userId.value : this.userId,
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
          ..write('usageCount: $usageCount, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    color,
    isDefault,
    categoryType,
    usageCount,
    userId,
    createdAt,
    updatedAt,
  );
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
          other.usageCount == this.usageCount &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<String> color;
  final Value<bool> isDefault;
  final Value<String> categoryType;
  final Value<int> usageCount;
  final Value<int?> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? color,
    Expression<bool>? isDefault,
    Expression<String>? categoryType,
    Expression<int>? usageCount,
    Expression<int>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (isDefault != null) 'is_default': isDefault,
      if (categoryType != null) 'category_type': categoryType,
      if (usageCount != null) 'usage_count': usageCount,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<String>? color,
    Value<bool>? isDefault,
    Value<String>? categoryType,
    Value<int>? usageCount,
    Value<int?>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      categoryType: categoryType ?? this.categoryType,
      usageCount: usageCount ?? this.usageCount,
      userId: userId ?? this.userId,
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
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
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
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('categoryType: $categoryType, ')
          ..write('usageCount: $usageCount, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurringIdMeta = const VerificationMeta(
    'recurringId',
  );
  @override
  late final GeneratedColumn<String> recurringId = GeneratedColumn<String>(
    'recurring_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recurringId,
    dueDate,
    amount,
    description,
    categoryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_recurring';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingRecurringData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recurring_id')) {
      context.handle(
        _recurringIdMeta,
        recurringId.isAcceptableOrUnknown(
          data['recurring_id']!,
          _recurringIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurringIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingRecurringData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingRecurringData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recurringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_id'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingRecurringTable createAlias(String alias) {
    return $PendingRecurringTable(attachedDatabase, alias);
  }
}

class PendingRecurringData extends DataClass
    implements Insertable<PendingRecurringData> {
  final String id;
  final String recurringId;
  final DateTime dueDate;
  final double amount;
  final String description;
  final String? categoryId;
  final DateTime createdAt;
  const PendingRecurringData({
    required this.id,
    required this.recurringId,
    required this.dueDate,
    required this.amount,
    required this.description,
    this.categoryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
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

  factory PendingRecurringData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingRecurringData(
      id: serializer.fromJson<String>(json['id']),
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
      'id': serializer.toJson<String>(id),
      'recurringId': serializer.toJson<String>(recurringId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<String?>(categoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingRecurringData copyWith({
    String? id,
    String? recurringId,
    DateTime? dueDate,
    double? amount,
    String? description,
    Value<String?> categoryId = const Value.absent(),
    DateTime? createdAt,
  }) => PendingRecurringData(
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
      recurringId: data.recurringId.present
          ? data.recurringId.value
          : this.recurringId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
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
    id,
    recurringId,
    dueDate,
    amount,
    description,
    categoryId,
    createdAt,
  );
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
  final Value<String> id;
  final Value<String> recurringId;
  final Value<DateTime> dueDate;
  final Value<double> amount;
  final Value<String> description;
  final Value<String?> categoryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingRecurringCompanion({
    this.id = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingRecurringCompanion.insert({
    required String id,
    required String recurringId,
    required DateTime dueDate,
    required double amount,
    required String description,
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recurringId = Value(recurringId),
       dueDate = Value(dueDate),
       amount = Value(amount),
       description = Value(description);
  static Insertable<PendingRecurringData> custom({
    Expression<String>? id,
    Expression<String>? recurringId,
    Expression<DateTime>? dueDate,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recurringId != null) 'recurring_id': recurringId,
      if (dueDate != null) 'due_date': dueDate,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingRecurringCompanion copyWith({
    Value<String>? id,
    Value<String>? recurringId,
    Value<DateTime>? dueDate,
    Value<double>? amount,
    Value<String>? description,
    Value<String?>? categoryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingRecurringCompanion(
      id: id ?? this.id,
      recurringId: recurringId ?? this.recurringId,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerWordsMeta = const VerificationMeta(
    'triggerWords',
  );
  @override
  late final GeneratedColumn<String> triggerWords = GeneratedColumn<String>(
    'trigger_words',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPatternMeta = const VerificationMeta(
    'amountPattern',
  );
  @override
  late final GeneratedColumn<String> amountPattern = GeneratedColumn<String>(
    'amount_pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datePatternMeta = const VerificationMeta(
    'datePattern',
  );
  @override
  late final GeneratedColumn<String> datePattern = GeneratedColumn<String>(
    'date_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
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
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parsing_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParsingRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('trigger_words')) {
      context.handle(
        _triggerWordsMeta,
        triggerWords.isAcceptableOrUnknown(
          data['trigger_words']!,
          _triggerWordsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerWordsMeta);
    }
    if (data.containsKey('amount_pattern')) {
      context.handle(
        _amountPatternMeta,
        amountPattern.isAcceptableOrUnknown(
          data['amount_pattern']!,
          _amountPatternMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPatternMeta);
    }
    if (data.containsKey('date_pattern')) {
      context.handle(
        _datePatternMeta,
        datePattern.isAcceptableOrUnknown(
          data['date_pattern']!,
          _datePatternMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParsingRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParsingRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      triggerWords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_words'],
      )!,
      amountPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_pattern'],
      )!,
      datePattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_pattern'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
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
  const ParsingRule({
    required this.id,
    required this.name,
    required this.triggerWords,
    required this.amountPattern,
    this.datePattern,
    this.categoryId,
    required this.sourceType,
    required this.isEnabled,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });
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

  factory ParsingRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  ParsingRule copyWith({
    String? id,
    String? name,
    String? triggerWords,
    String? amountPattern,
    Value<String?> datePattern = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    String? sourceType,
    bool? isEnabled,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ParsingRule(
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
      datePattern: data.datePattern.present
          ? data.datePattern.value
          : this.datePattern,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
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
    updatedAt,
  );
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
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       triggerWords = Value(triggerWords),
       amountPattern = Value(amountPattern),
       sourceType = Value(sourceType);
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

  ParsingRulesCompanion copyWith({
    Value<String>? id,
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
    Value<int>? rowid,
  }) {
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNameMeta = const VerificationMeta(
    'contactName',
  );
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
    'contact_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMonitoredMeta = const VerificationMeta(
    'isMonitored',
  );
  @override
  late final GeneratedColumn<bool> isMonitored = GeneratedColumn<bool>(
    'is_monitored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_monitored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoCreateOptionMeta = const VerificationMeta(
    'autoCreateOption',
  );
  @override
  late final GeneratedColumn<int> autoCreateOption = GeneratedColumn<int>(
    'auto_create_option',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    contactName,
    isMonitored,
    autoCreateOption,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('contact_name')) {
      context.handle(
        _contactNameMeta,
        contactName.isAcceptableOrUnknown(
          data['contact_name']!,
          _contactNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactNameMeta);
    }
    if (data.containsKey('is_monitored')) {
      context.handle(
        _isMonitoredMeta,
        isMonitored.isAcceptableOrUnknown(
          data['is_monitored']!,
          _isMonitoredMeta,
        ),
      );
    }
    if (data.containsKey('auto_create_option')) {
      context.handle(
        _autoCreateOptionMeta,
        autoCreateOption.isAcceptableOrUnknown(
          data['auto_create_option']!,
          _autoCreateOptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      contactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_name'],
      )!,
      isMonitored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_monitored'],
      )!,
      autoCreateOption: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_create_option'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
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
  const MessageSource({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.isMonitored,
    required this.autoCreateOption,
    required this.createdAt,
    required this.updatedAt,
  });
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

  factory MessageSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  MessageSource copyWith({
    String? id,
    String? contactId,
    String? contactName,
    bool? isMonitored,
    int? autoCreateOption,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MessageSource(
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
      contactName: data.contactName.present
          ? data.contactName.value
          : this.contactName,
      isMonitored: data.isMonitored.present
          ? data.isMonitored.value
          : this.isMonitored,
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
  int get hashCode => Object.hash(
    id,
    contactId,
    contactName,
    isMonitored,
    autoCreateOption,
    createdAt,
    updatedAt,
  );
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
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contactId = Value(contactId),
       contactName = Value(contactName);
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

  MessageSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? contactId,
    Value<String>? contactName,
    Value<bool>? isMonitored,
    Value<int>? autoCreateOption,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES message_sources (id)',
    ),
  );
  static const VerificationMeta _sampleMessageMeta = const VerificationMeta(
    'sampleMessage',
  );
  @override
  late final GeneratedColumn<String> sampleMessage = GeneratedColumn<String>(
    'sample_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerWordMeta = const VerificationMeta(
    'triggerWord',
  );
  @override
  late final GeneratedColumn<String> triggerWord = GeneratedColumn<String>(
    'trigger_word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPatternMeta = const VerificationMeta(
    'amountPattern',
  );
  @override
  late final GeneratedColumn<String> amountPattern = GeneratedColumn<String>(
    'amount_pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionPatternMeta =
      const VerificationMeta('descriptionPattern');
  @override
  late final GeneratedColumn<String> descriptionPattern =
      GeneratedColumn<String>(
        'description_pattern',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _datePatternMeta = const VerificationMeta(
    'datePattern',
  );
  @override
  late final GeneratedColumn<String> datePattern = GeneratedColumn<String>(
    'date_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedAmountMeta = const VerificationMeta(
    'selectedAmount',
  );
  @override
  late final GeneratedColumn<String> selectedAmount = GeneratedColumn<String>(
    'selected_amount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
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
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('sample_message')) {
      context.handle(
        _sampleMessageMeta,
        sampleMessage.isAcceptableOrUnknown(
          data['sample_message']!,
          _sampleMessageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sampleMessageMeta);
    }
    if (data.containsKey('trigger_word')) {
      context.handle(
        _triggerWordMeta,
        triggerWord.isAcceptableOrUnknown(
          data['trigger_word']!,
          _triggerWordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerWordMeta);
    }
    if (data.containsKey('amount_pattern')) {
      context.handle(
        _amountPatternMeta,
        amountPattern.isAcceptableOrUnknown(
          data['amount_pattern']!,
          _amountPatternMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPatternMeta);
    }
    if (data.containsKey('description_pattern')) {
      context.handle(
        _descriptionPatternMeta,
        descriptionPattern.isAcceptableOrUnknown(
          data['description_pattern']!,
          _descriptionPatternMeta,
        ),
      );
    }
    if (data.containsKey('date_pattern')) {
      context.handle(
        _datePatternMeta,
        datePattern.isAcceptableOrUnknown(
          data['date_pattern']!,
          _datePatternMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('selected_amount')) {
      context.handle(
        _selectedAmountMeta,
        selectedAmount.isAcceptableOrUnknown(
          data['selected_amount']!,
          _selectedAmountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sampleMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sample_message'],
      )!,
      triggerWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_word'],
      )!,
      amountPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_pattern'],
      )!,
      descriptionPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_pattern'],
      ),
      datePattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_pattern'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      selectedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_amount'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
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
  const ExpenseTemplate({
    required this.id,
    required this.sourceId,
    required this.sampleMessage,
    required this.triggerWord,
    required this.amountPattern,
    this.descriptionPattern,
    this.datePattern,
    this.categoryId,
    this.selectedAmount,
    required this.createdAt,
    required this.updatedAt,
  });
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

  factory ExpenseTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseTemplate(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sampleMessage: serializer.fromJson<String>(json['sampleMessage']),
      triggerWord: serializer.fromJson<String>(json['triggerWord']),
      amountPattern: serializer.fromJson<String>(json['amountPattern']),
      descriptionPattern: serializer.fromJson<String?>(
        json['descriptionPattern'],
      ),
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

  ExpenseTemplate copyWith({
    String? id,
    String? sourceId,
    String? sampleMessage,
    String? triggerWord,
    String? amountPattern,
    Value<String?> descriptionPattern = const Value.absent(),
    Value<String?> datePattern = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> selectedAmount = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExpenseTemplate(
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
    selectedAmount: selectedAmount.present
        ? selectedAmount.value
        : this.selectedAmount,
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
      triggerWord: data.triggerWord.present
          ? data.triggerWord.value
          : this.triggerWord,
      amountPattern: data.amountPattern.present
          ? data.amountPattern.value
          : this.amountPattern,
      descriptionPattern: data.descriptionPattern.present
          ? data.descriptionPattern.value
          : this.descriptionPattern,
      datePattern: data.datePattern.present
          ? data.datePattern.value
          : this.datePattern,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
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
    updatedAt,
  );
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
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       sampleMessage = Value(sampleMessage),
       triggerWord = Value(triggerWord),
       amountPattern = Value(amountPattern);
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

  ExpenseTemplatesCompanion copyWith({
    Value<String>? id,
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
    Value<int>? rowid,
  }) {
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolloverEnabledMeta = const VerificationMeta(
    'rolloverEnabled',
  );
  @override
  late final GeneratedColumn<bool> rolloverEnabled = GeneratedColumn<bool>(
    'rollover_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rollover_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rolloverAmountMeta = const VerificationMeta(
    'rolloverAmount',
  );
  @override
  late final GeneratedColumn<double> rolloverAmount = GeneratedColumn<double>(
    'rollover_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amount,
    period,
    startDate,
    rolloverEnabled,
    rolloverAmount,
    isEnabled,
    userId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('rollover_enabled')) {
      context.handle(
        _rolloverEnabledMeta,
        rolloverEnabled.isAcceptableOrUnknown(
          data['rollover_enabled']!,
          _rolloverEnabledMeta,
        ),
      );
    }
    if (data.containsKey('rollover_amount')) {
      context.handle(
        _rolloverAmountMeta,
        rolloverAmount.isAcceptableOrUnknown(
          data['rollover_amount']!,
          _rolloverAmountMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      rolloverEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rollover_enabled'],
      )!,
      rolloverAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rollover_amount'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String name;
  final double amount;
  final String period;
  final DateTime startDate;
  final bool rolloverEnabled;
  final double rolloverAmount;
  final bool isEnabled;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.rolloverEnabled,
    required this.rolloverAmount,
    required this.isEnabled,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['rollover_enabled'] = Variable<bool>(rolloverEnabled);
    map['rollover_amount'] = Variable<double>(rolloverAmount);
    map['is_enabled'] = Variable<bool>(isEnabled);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      period: Value(period),
      startDate: Value(startDate),
      rolloverEnabled: Value(rolloverEnabled),
      rolloverAmount: Value(rolloverAmount),
      isEnabled: Value(isEnabled),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      rolloverEnabled: serializer.fromJson<bool>(json['rolloverEnabled']),
      rolloverAmount: serializer.fromJson<double>(json['rolloverAmount']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      userId: serializer.fromJson<int?>(json['userId']),
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
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'rolloverEnabled': serializer.toJson<bool>(rolloverEnabled),
      'rolloverAmount': serializer.toJson<double>(rolloverAmount),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'userId': serializer.toJson<int?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    String? period,
    DateTime? startDate,
    bool? rolloverEnabled,
    double? rolloverAmount,
    bool? isEnabled,
    Value<int?> userId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Budget(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
    rolloverAmount: rolloverAmount ?? this.rolloverAmount,
    isEnabled: isEnabled ?? this.isEnabled,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
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
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('rolloverAmount: $rolloverAmount, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    amount,
    period,
    startDate,
    rolloverEnabled,
    rolloverAmount,
    isEnabled,
    userId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.rolloverEnabled == this.rolloverEnabled &&
          other.rolloverAmount == this.rolloverAmount &&
          other.isEnabled == this.isEnabled &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<bool> rolloverEnabled;
  final Value<double> rolloverAmount;
  final Value<bool> isEnabled;
  final Value<int?> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.rolloverEnabled = const Value.absent(),
    this.rolloverAmount = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String name,
    required double amount,
    required String period,
    required DateTime startDate,
    this.rolloverEnabled = const Value.absent(),
    this.rolloverAmount = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       amount = Value(amount),
       period = Value(period),
       startDate = Value(startDate);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<bool>? rolloverEnabled,
    Expression<double>? rolloverAmount,
    Expression<bool>? isEnabled,
    Expression<int>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (rolloverEnabled != null) 'rollover_enabled': rolloverEnabled,
      if (rolloverAmount != null) 'rollover_amount': rolloverAmount,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? amount,
    Value<String>? period,
    Value<DateTime>? startDate,
    Value<bool>? rolloverEnabled,
    Value<double>? rolloverAmount,
    Value<bool>? isEnabled,
    Value<int?>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      isEnabled: isEnabled ?? this.isEnabled,
      userId: userId ?? this.userId,
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
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
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
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('rolloverAmount: $rolloverAmount, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('userId: $userId, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextOccurrenceMeta = const VerificationMeta(
    'nextOccurrence',
  );
  @override
  late final GeneratedColumn<DateTime> nextOccurrence =
      GeneratedColumn<DateTime>(
        'next_occurrence',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoCreateExpenseMeta = const VerificationMeta(
    'autoCreateExpense',
  );
  @override
  late final GeneratedColumn<bool> autoCreateExpense = GeneratedColumn<bool>(
    'auto_create_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_create_expense" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
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
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTransaction> instance, {
    bool isInserting = false,
  }) {
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
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('next_occurrence')) {
      context.handle(
        _nextOccurrenceMeta,
        nextOccurrence.isAcceptableOrUnknown(
          data['next_occurrence']!,
          _nextOccurrenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextOccurrenceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('auto_create_expense')) {
      context.handle(
        _autoCreateExpenseMeta,
        autoCreateExpense.isAcceptableOrUnknown(
          data['auto_create_expense']!,
          _autoCreateExpenseMeta,
        ),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      nextOccurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_occurrence'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      autoCreateExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_create_expense'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
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
  const RecurringTransaction({
    required this.id,
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
    required this.updatedAt,
  });
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

  factory RecurringTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  RecurringTransaction copyWith({
    String? id,
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
    DateTime? updatedAt,
  }) => RecurringTransaction(
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
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
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
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
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
    updatedAt,
  );
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
  }) : id = Value(id),
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

  RecurringTransactionsCompanion copyWith({
    Value<String>? id,
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
    Value<int>? rowid,
  }) {
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

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    email,
    displayName,
    photoUrl,
    createdAt,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  const User({
    required this.id,
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      uid: Value(uid),
      email: Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: Value(createdAt),
      lastLoginAt: Value(lastLoginAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastLoginAt: serializer.fromJson<DateTime>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastLoginAt': serializer.toJson<DateTime>(lastLoginAt),
    };
  }

  User copyWith({
    int? id,
    String? uid,
    String? email,
    Value<String?> displayName = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) => User(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    email: email ?? this.email,
    displayName: displayName.present ? displayName.value : this.displayName,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uid,
    email,
    displayName,
    photoUrl,
    createdAt,
    lastLoginAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.lastLoginAt == this.lastLoginAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> email;
  final Value<String?> displayName;
  final Value<String?> photoUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastLoginAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String email,
    this.displayName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
  }) : uid = Value(uid),
       email = Value(email);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastLoginAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String>? email,
    Value<String?>? displayName,
    Value<String?>? photoUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastLoginAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    recordId,
    action,
    payload,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityTable;
  final String recordId;
  final String action;
  final String payload;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const SyncQueueData({
    required this.id,
    required this.entityTable,
    required this.recordId,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['record_id'] = Variable<String>(recordId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      recordId: Value(recordId),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'recordId': serializer.toJson<String>(recordId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityTable,
    String? recordId,
    String? action,
    String? payload,
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    recordId: recordId ?? this.recordId,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    recordId,
    action,
    payload,
    createdAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.recordId == this.recordId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityTable;
  final Value<String> recordId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityTable,
    required String recordId,
    required String action,
    required String payload,
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  }) : entityTable = Value(entityTable),
       recordId = Value(recordId),
       action = Value(action),
       payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityTable,
    Expression<String>? recordId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (recordId != null) 'record_id': recordId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityTable,
    Value<String>? recordId,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<DateTime?>? syncedAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $PendingRecurringTable pendingRecurring = $PendingRecurringTable(
    this,
  );
  late final $ParsingRulesTable parsingRules = $ParsingRulesTable(this);
  late final $MessageSourcesTable messageSources = $MessageSourcesTable(this);
  late final $ExpenseTemplatesTable expenseTemplates = $ExpenseTemplatesTable(
    this,
  );
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final RecordDao recordDao = RecordDao(this as AppDatabase);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final RecurringDao recurringDao = RecurringDao(this as AppDatabase);
  late final BudgetDao budgetDao = BudgetDao(this as AppDatabase);
  late final PendingRecurringDao pendingRecurringDao = PendingRecurringDao(
    this as AppDatabase,
  );
  late final ParsingRuleDao parsingRuleDao = ParsingRuleDao(
    this as AppDatabase,
  );
  late final MessageTemplateDao messageTemplateDao = MessageTemplateDao(
    this as AppDatabase,
  );
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
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
    users,
    syncQueue,
    appSettings,
  ];
}

typedef $$RecordsTableCreateCompanionBuilder =
    RecordsCompanion Function({
      required String id,
      required double amount,
      required String description,
      required DateTime date,
      Value<String?> categoryId,
      Value<String?> budgetId,
      Value<String> source,
      Value<String?> sourceId,
      required String recordType,
      Value<int?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RecordsTableUpdateCompanionBuilder =
    RecordsCompanion Function({
      Value<String> id,
      Value<double> amount,
      Value<String> description,
      Value<DateTime> date,
      Value<String?> categoryId,
      Value<String?> budgetId,
      Value<String> source,
      Value<String?> sourceId,
      Value<String> recordType,
      Value<int?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecordsTable,
          Record,
          $$RecordsTableFilterComposer,
          $$RecordsTableOrderingComposer,
          $$RecordsTableCreateCompanionBuilder,
          $$RecordsTableUpdateCompanionBuilder
        > {
  $$RecordsTableTableManager(_$AppDatabase db, $RecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$RecordsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$RecordsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> budgetId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordsCompanion(
                id: id,
                amount: amount,
                description: description,
                date: date,
                categoryId: categoryId,
                budgetId: budgetId,
                source: source,
                sourceId: sourceId,
                recordType: recordType,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double amount,
                required String description,
                required DateTime date,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> budgetId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                required String recordType,
                Value<int?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordsCompanion.insert(
                id: id,
                amount: amount,
                description: description,
                date: date,
                categoryId: categoryId,
                budgetId: budgetId,
                source: source,
                sourceId: sourceId,
                recordType: recordType,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$RecordsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get date => $state.composableBuilder(
    column: $state.table.date,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get budgetId => $state.composableBuilder(
    column: $state.table.budgetId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get source => $state.composableBuilder(
    column: $state.table.source,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get sourceId => $state.composableBuilder(
    column: $state.table.sourceId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get recordType => $state.composableBuilder(
    column: $state.table.recordType,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$RecordsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
    column: $state.table.date,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get budgetId => $state.composableBuilder(
    column: $state.table.budgetId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get source => $state.composableBuilder(
    column: $state.table.source,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get sourceId => $state.composableBuilder(
    column: $state.table.sourceId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get recordType => $state.composableBuilder(
    column: $state.table.recordType,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<String> emoji,
      Value<String> color,
      Value<bool> isDefault,
      Value<String> categoryType,
      Value<int> usageCount,
      Value<int?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> emoji,
      Value<String> color,
      Value<bool> isDefault,
      Value<String> categoryType,
      Value<int> usageCount,
      Value<int?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$CategoriesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$CategoriesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String> categoryType = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                isDefault: isDefault,
                categoryType: categoryType,
                usageCount: usageCount,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> emoji = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String> categoryType = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                color: color,
                isDefault: isDefault,
                categoryType: categoryType,
                usageCount: usageCount,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$CategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get emoji => $state.composableBuilder(
    column: $state.table.emoji,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get color => $state.composableBuilder(
    column: $state.table.color,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
    column: $state.table.isDefault,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get categoryType => $state.composableBuilder(
    column: $state.table.categoryType,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get usageCount => $state.composableBuilder(
    column: $state.table.usageCount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$CategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get emoji => $state.composableBuilder(
    column: $state.table.emoji,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get color => $state.composableBuilder(
    column: $state.table.color,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
    column: $state.table.isDefault,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get categoryType => $state.composableBuilder(
    column: $state.table.categoryType,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get usageCount => $state.composableBuilder(
    column: $state.table.usageCount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$PendingRecurringTableCreateCompanionBuilder =
    PendingRecurringCompanion Function({
      required String id,
      required String recurringId,
      required DateTime dueDate,
      required double amount,
      required String description,
      Value<String?> categoryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PendingRecurringTableUpdateCompanionBuilder =
    PendingRecurringCompanion Function({
      Value<String> id,
      Value<String> recurringId,
      Value<DateTime> dueDate,
      Value<double> amount,
      Value<String> description,
      Value<String?> categoryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingRecurringTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingRecurringTable,
          PendingRecurringData,
          $$PendingRecurringTableFilterComposer,
          $$PendingRecurringTableOrderingComposer,
          $$PendingRecurringTableCreateCompanionBuilder,
          $$PendingRecurringTableUpdateCompanionBuilder
        > {
  $$PendingRecurringTableTableManager(
    _$AppDatabase db,
    $PendingRecurringTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$PendingRecurringTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$PendingRecurringTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recurringId = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingRecurringCompanion(
                id: id,
                recurringId: recurringId,
                dueDate: dueDate,
                amount: amount,
                description: description,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recurringId,
                required DateTime dueDate,
                required double amount,
                required String description,
                Value<String?> categoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingRecurringCompanion.insert(
                id: id,
                recurringId: recurringId,
                dueDate: dueDate,
                amount: amount,
                description: description,
                categoryId: categoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$PendingRecurringTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PendingRecurringTable> {
  $$PendingRecurringTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get recurringId => $state.composableBuilder(
    column: $state.table.recurringId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get dueDate => $state.composableBuilder(
    column: $state.table.dueDate,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$PendingRecurringTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PendingRecurringTable> {
  $$PendingRecurringTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get recurringId => $state.composableBuilder(
    column: $state.table.recurringId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get dueDate => $state.composableBuilder(
    column: $state.table.dueDate,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$ParsingRulesTableCreateCompanionBuilder =
    ParsingRulesCompanion Function({
      required String id,
      required String name,
      required String triggerWords,
      required String amountPattern,
      Value<String?> datePattern,
      Value<String?> categoryId,
      required String sourceType,
      Value<bool> isEnabled,
      Value<int> priority,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ParsingRulesTableUpdateCompanionBuilder =
    ParsingRulesCompanion Function({
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

class $$ParsingRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParsingRulesTable,
          ParsingRule,
          $$ParsingRulesTableFilterComposer,
          $$ParsingRulesTableOrderingComposer,
          $$ParsingRulesTableCreateCompanionBuilder,
          $$ParsingRulesTableUpdateCompanionBuilder
        > {
  $$ParsingRulesTableTableManager(_$AppDatabase db, $ParsingRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ParsingRulesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$ParsingRulesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
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
              }) => ParsingRulesCompanion(
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
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String triggerWords,
                required String amountPattern,
                Value<String?> datePattern = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required String sourceType,
                Value<bool> isEnabled = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParsingRulesCompanion.insert(
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
        ),
      );
}

class $$ParsingRulesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ParsingRulesTable> {
  $$ParsingRulesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get triggerWords => $state.composableBuilder(
    column: $state.table.triggerWords,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get amountPattern => $state.composableBuilder(
    column: $state.table.amountPattern,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get datePattern => $state.composableBuilder(
    column: $state.table.datePattern,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get sourceType => $state.composableBuilder(
    column: $state.table.sourceType,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isEnabled => $state.composableBuilder(
    column: $state.table.isEnabled,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get priority => $state.composableBuilder(
    column: $state.table.priority,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$ParsingRulesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ParsingRulesTable> {
  $$ParsingRulesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get triggerWords => $state.composableBuilder(
    column: $state.table.triggerWords,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get amountPattern => $state.composableBuilder(
    column: $state.table.amountPattern,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get datePattern => $state.composableBuilder(
    column: $state.table.datePattern,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get sourceType => $state.composableBuilder(
    column: $state.table.sourceType,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isEnabled => $state.composableBuilder(
    column: $state.table.isEnabled,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get priority => $state.composableBuilder(
    column: $state.table.priority,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$MessageSourcesTableCreateCompanionBuilder =
    MessageSourcesCompanion Function({
      required String id,
      required String contactId,
      required String contactName,
      Value<bool> isMonitored,
      Value<int> autoCreateOption,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$MessageSourcesTableUpdateCompanionBuilder =
    MessageSourcesCompanion Function({
      Value<String> id,
      Value<String> contactId,
      Value<String> contactName,
      Value<bool> isMonitored,
      Value<int> autoCreateOption,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MessageSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageSourcesTable,
          MessageSource,
          $$MessageSourcesTableFilterComposer,
          $$MessageSourcesTableOrderingComposer,
          $$MessageSourcesTableCreateCompanionBuilder,
          $$MessageSourcesTableUpdateCompanionBuilder
        > {
  $$MessageSourcesTableTableManager(
    _$AppDatabase db,
    $MessageSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$MessageSourcesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$MessageSourcesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contactId = const Value.absent(),
                Value<String> contactName = const Value.absent(),
                Value<bool> isMonitored = const Value.absent(),
                Value<int> autoCreateOption = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageSourcesCompanion(
                id: id,
                contactId: contactId,
                contactName: contactName,
                isMonitored: isMonitored,
                autoCreateOption: autoCreateOption,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contactId,
                required String contactName,
                Value<bool> isMonitored = const Value.absent(),
                Value<int> autoCreateOption = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageSourcesCompanion.insert(
                id: id,
                contactId: contactId,
                contactName: contactName,
                isMonitored: isMonitored,
                autoCreateOption: autoCreateOption,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$MessageSourcesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MessageSourcesTable> {
  $$MessageSourcesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get contactId => $state.composableBuilder(
    column: $state.table.contactId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get contactName => $state.composableBuilder(
    column: $state.table.contactName,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isMonitored => $state.composableBuilder(
    column: $state.table.isMonitored,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get autoCreateOption => $state.composableBuilder(
    column: $state.table.autoCreateOption,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ComposableFilter expenseTemplatesRefs(
    ComposableFilter Function($$ExpenseTemplatesTableFilterComposer f) f,
  ) {
    final $$ExpenseTemplatesTableFilterComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $state.db.expenseTemplates,
          getReferencedColumn: (t) => t.sourceId,
          builder: (joinBuilder, parentComposers) =>
              $$ExpenseTemplatesTableFilterComposer(
                ComposerState(
                  $state.db,
                  $state.db.expenseTemplates,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return f(composer);
  }
}

class $$MessageSourcesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MessageSourcesTable> {
  $$MessageSourcesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get contactId => $state.composableBuilder(
    column: $state.table.contactId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get contactName => $state.composableBuilder(
    column: $state.table.contactName,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isMonitored => $state.composableBuilder(
    column: $state.table.isMonitored,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get autoCreateOption => $state.composableBuilder(
    column: $state.table.autoCreateOption,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$ExpenseTemplatesTableCreateCompanionBuilder =
    ExpenseTemplatesCompanion Function({
      required String id,
      required String sourceId,
      required String sampleMessage,
      required String triggerWord,
      required String amountPattern,
      Value<String?> descriptionPattern,
      Value<String?> datePattern,
      Value<String?> categoryId,
      Value<String?> selectedAmount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ExpenseTemplatesTableUpdateCompanionBuilder =
    ExpenseTemplatesCompanion Function({
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

class $$ExpenseTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseTemplatesTable,
          ExpenseTemplate,
          $$ExpenseTemplatesTableFilterComposer,
          $$ExpenseTemplatesTableOrderingComposer,
          $$ExpenseTemplatesTableCreateCompanionBuilder,
          $$ExpenseTemplatesTableUpdateCompanionBuilder
        > {
  $$ExpenseTemplatesTableTableManager(
    _$AppDatabase db,
    $ExpenseTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ExpenseTemplatesTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$ExpenseTemplatesTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
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
              }) => ExpenseTemplatesCompanion(
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
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String sampleMessage,
                required String triggerWord,
                required String amountPattern,
                Value<String?> descriptionPattern = const Value.absent(),
                Value<String?> datePattern = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> selectedAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseTemplatesCompanion.insert(
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
        ),
      );
}

class $$ExpenseTemplatesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ExpenseTemplatesTable> {
  $$ExpenseTemplatesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get sampleMessage => $state.composableBuilder(
    column: $state.table.sampleMessage,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get triggerWord => $state.composableBuilder(
    column: $state.table.triggerWord,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get amountPattern => $state.composableBuilder(
    column: $state.table.amountPattern,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get descriptionPattern => $state.composableBuilder(
    column: $state.table.descriptionPattern,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get datePattern => $state.composableBuilder(
    column: $state.table.datePattern,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get selectedAmount => $state.composableBuilder(
    column: $state.table.selectedAmount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  $$MessageSourcesTableFilterComposer get sourceId {
    final $$MessageSourcesTableFilterComposer composer = $state.composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $state.db.messageSources,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, parentComposers) =>
          $$MessageSourcesTableFilterComposer(
            ComposerState(
              $state.db,
              $state.db.messageSources,
              joinBuilder,
              parentComposers,
            ),
          ),
    );
    return composer;
  }
}

class $$ExpenseTemplatesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ExpenseTemplatesTable> {
  $$ExpenseTemplatesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get sampleMessage => $state.composableBuilder(
    column: $state.table.sampleMessage,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get triggerWord => $state.composableBuilder(
    column: $state.table.triggerWord,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get amountPattern => $state.composableBuilder(
    column: $state.table.amountPattern,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get descriptionPattern => $state.composableBuilder(
    column: $state.table.descriptionPattern,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get datePattern => $state.composableBuilder(
    column: $state.table.datePattern,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get selectedAmount => $state.composableBuilder(
    column: $state.table.selectedAmount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  $$MessageSourcesTableOrderingComposer get sourceId {
    final $$MessageSourcesTableOrderingComposer composer = $state
        .composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceId,
          referencedTable: $state.db.messageSources,
          getReferencedColumn: (t) => t.id,
          builder: (joinBuilder, parentComposers) =>
              $$MessageSourcesTableOrderingComposer(
                ComposerState(
                  $state.db,
                  $state.db.messageSources,
                  joinBuilder,
                  parentComposers,
                ),
              ),
        );
    return composer;
  }
}

typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String name,
      required double amount,
      required String period,
      required DateTime startDate,
      Value<bool> rolloverEnabled,
      Value<double> rolloverAmount,
      Value<bool> isEnabled,
      Value<int?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> amount,
      Value<String> period,
      Value<DateTime> startDate,
      Value<bool> rolloverEnabled,
      Value<double> rolloverAmount,
      Value<bool> isEnabled,
      Value<int?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$BudgetsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$BudgetsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<bool> rolloverEnabled = const Value.absent(),
                Value<double> rolloverAmount = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                name: name,
                amount: amount,
                period: period,
                startDate: startDate,
                rolloverEnabled: rolloverEnabled,
                rolloverAmount: rolloverAmount,
                isEnabled: isEnabled,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double amount,
                required String period,
                required DateTime startDate,
                Value<bool> rolloverEnabled = const Value.absent(),
                Value<double> rolloverAmount = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                name: name,
                amount: amount,
                period: period,
                startDate: startDate,
                rolloverEnabled: rolloverEnabled,
                rolloverAmount: rolloverAmount,
                isEnabled: isEnabled,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$BudgetsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get period => $state.composableBuilder(
    column: $state.table.period,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
    column: $state.table.startDate,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get rolloverEnabled => $state.composableBuilder(
    column: $state.table.rolloverEnabled,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<double> get rolloverAmount => $state.composableBuilder(
    column: $state.table.rolloverAmount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isEnabled => $state.composableBuilder(
    column: $state.table.isEnabled,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$BudgetsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get name => $state.composableBuilder(
    column: $state.table.name,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get period => $state.composableBuilder(
    column: $state.table.period,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
    column: $state.table.startDate,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get rolloverEnabled => $state.composableBuilder(
    column: $state.table.rolloverEnabled,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<double> get rolloverAmount => $state.composableBuilder(
    column: $state.table.rolloverAmount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isEnabled => $state.composableBuilder(
    column: $state.table.isEnabled,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get userId => $state.composableBuilder(
    column: $state.table.userId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$RecurringTransactionsTableCreateCompanionBuilder =
    RecurringTransactionsCompanion Function({
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
typedef $$RecurringTransactionsTableUpdateCompanionBuilder =
    RecurringTransactionsCompanion Function({
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

class $$RecurringTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringTransaction,
          $$RecurringTransactionsTableFilterComposer,
          $$RecurringTransactionsTableOrderingComposer,
          $$RecurringTransactionsTableCreateCompanionBuilder,
          $$RecurringTransactionsTableUpdateCompanionBuilder
        > {
  $$RecurringTransactionsTableTableManager(
    _$AppDatabase db,
    $RecurringTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$RecurringTransactionsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$RecurringTransactionsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
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
              }) => RecurringTransactionsCompanion(
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
          createCompanionCallback:
              ({
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
              }) => RecurringTransactionsCompanion.insert(
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
        ),
      );
}

class $$RecurringTransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get frequency => $state.composableBuilder(
    column: $state.table.frequency,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
    column: $state.table.startDate,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get endDate => $state.composableBuilder(
    column: $state.table.endDate,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get nextOccurrence => $state.composableBuilder(
    column: $state.table.nextOccurrence,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get isActive => $state.composableBuilder(
    column: $state.table.isActive,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<bool> get autoCreateExpense => $state.composableBuilder(
    column: $state.table.autoCreateExpense,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<int> get dayOfMonth => $state.composableBuilder(
    column: $state.table.dayOfMonth,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$RecurringTransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get description => $state.composableBuilder(
    column: $state.table.description,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<double> get amount => $state.composableBuilder(
    column: $state.table.amount,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
    column: $state.table.categoryId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get frequency => $state.composableBuilder(
    column: $state.table.frequency,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
    column: $state.table.startDate,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get endDate => $state.composableBuilder(
    column: $state.table.endDate,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get nextOccurrence => $state.composableBuilder(
    column: $state.table.nextOccurrence,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
    column: $state.table.isActive,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<bool> get autoCreateExpense => $state.composableBuilder(
    column: $state.table.autoCreateExpense,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<int> get dayOfMonth => $state.composableBuilder(
    column: $state.table.dayOfMonth,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String uid,
      required String email,
      Value<String?> displayName,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
      Value<DateTime> lastLoginAt,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String> email,
      Value<String?> displayName,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
      Value<DateTime> lastLoginAt,
    });

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$UsersTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$UsersTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastLoginAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                uid: uid,
                email: email,
                displayName: displayName,
                photoUrl: photoUrl,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uid,
                required String email,
                Value<String?> displayName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastLoginAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                uid: uid,
                email: email,
                displayName: displayName,
                photoUrl: photoUrl,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
              ),
        ),
      );
}

class $$UsersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get uid => $state.composableBuilder(
    column: $state.table.uid,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get email => $state.composableBuilder(
    column: $state.table.email,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get displayName => $state.composableBuilder(
    column: $state.table.displayName,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get photoUrl => $state.composableBuilder(
    column: $state.table.photoUrl,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get lastLoginAt => $state.composableBuilder(
    column: $state.table.lastLoginAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$UsersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get uid => $state.composableBuilder(
    column: $state.table.uid,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get email => $state.composableBuilder(
    column: $state.table.email,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get displayName => $state.composableBuilder(
    column: $state.table.displayName,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get photoUrl => $state.composableBuilder(
    column: $state.table.photoUrl,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $state.composableBuilder(
    column: $state.table.lastLoginAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityTable,
      required String recordId,
      required String action,
      required String payload,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityTable,
      Value<String> recordId,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
    });

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$SyncQueueTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$SyncQueueTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityTable: entityTable,
                recordId: recordId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityTable,
                required String recordId,
                required String action,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityTable: entityTable,
                recordId: recordId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
        ),
      );
}

class $$SyncQueueTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get entityTable => $state.composableBuilder(
    column: $state.table.entityTable,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get recordId => $state.composableBuilder(
    column: $state.table.recordId,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get action => $state.composableBuilder(
    column: $state.table.action,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get payload => $state.composableBuilder(
    column: $state.table.payload,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$SyncQueueTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
    column: $state.table.id,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get entityTable => $state.composableBuilder(
    column: $state.table.entityTable,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get recordId => $state.composableBuilder(
    column: $state.table.recordId,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get action => $state.composableBuilder(
    column: $state.table.action,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get payload => $state.composableBuilder(
    column: $state.table.payload,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
    column: $state.table.createdAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
    column: $state.table.syncedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$AppSettingsTableFilterComposer(
            ComposerState(db, table),
          ),
          orderingComposer: $$AppSettingsTableOrderingComposer(
            ComposerState(db, table),
          ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
        ),
      );
}

class $$AppSettingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
    column: $state.table.key,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<String> get value => $state.composableBuilder(
    column: $state.table.value,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnFilters(column, joinBuilders: joinBuilders),
  );
}

class $$AppSettingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
    column: $state.table.key,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<String> get value => $state.composableBuilder(
    column: $state.table.value,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
    column: $state.table.updatedAt,
    builder: (column, joinBuilders) =>
        ColumnOrderings(column, joinBuilders: joinBuilders),
  );
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
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
