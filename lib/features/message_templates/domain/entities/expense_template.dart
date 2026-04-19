import 'package:equatable/equatable.dart';

class ExpenseTemplate extends Equatable {
  final String id;
  final String sourceId; // Refers to MessageSource.id
  final String sampleMessage;
  final String triggerWord;
  final String amountPattern;
  final String? descriptionPattern;
  final String? datePattern;
  final String? categoryId;
  final String?
  selectedAmount; // The exact amount value the user selected during template creation
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

  ExpenseTemplate copyWith({
    String? id,
    String? sourceId,
    String? sampleMessage,
    String? triggerWord,
    String? amountPattern,
    String? descriptionPattern,
    String? datePattern,
    String? categoryId,
    String? selectedAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseTemplate(
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
    );
  }

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
}
