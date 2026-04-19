import 'package:equatable/equatable.dart';
import 'expense_source.dart';

class Expense extends Equatable {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final int? categoryId;
  final ExpenseSource source;
  final String? sourceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    this.categoryId,
    this.source = ExpenseSource.manual,
    this.sourceId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFromScan => source != ExpenseSource.manual;

  Expense copyWith({
    int? id,
    double? amount,
    String? description,
    DateTime? date,
    int? categoryId,
    ExpenseSource? source,
    String? sourceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    date,
    categoryId,
    source,
    sourceId,
    createdAt,
    updatedAt,
  ];
}
