import 'package:equatable/equatable.dart';

class ExpenseTemplate extends Equatable {
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

  @override
  List<Object?> get props => [
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

  ExpenseTemplate copyWith({
    required String id,
    required String sourceId,
    required String sampleMessage,
    required String triggerWord,
    required String amountPattern,
    String? descriptionPattern,
    String? datePattern,
    String? categoryId,
    String? selectedAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ExpenseTemplate(
      id: id,
      sourceId: sourceId,
      sampleMessage: sampleMessage,
      triggerWord: triggerWord,
      amountPattern: amountPattern,
      descriptionPattern: descriptionPattern ?? this.descriptionPattern,
      datePattern: datePattern ?? this.datePattern,
      categoryId: categoryId ?? this.categoryId,
      selectedAmount: selectedAmount ?? this.selectedAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
