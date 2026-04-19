import 'package:equatable/equatable.dart';

enum SourceType { sms, email, both }

class ParsingRule extends Equatable {
  final String id;
  final String name;
  final List<String> triggerWords;
  final String amountPattern;
  final String? datePattern;
  final String? categoryId;
  final SourceType sourceType;
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

  ParsingRule copyWith({
    String? id,
    String? name,
    List<String>? triggerWords,
    String? amountPattern,
    String? datePattern,
    String? categoryId,
    SourceType? sourceType,
    bool? isEnabled,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParsingRule(
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
    );
  }

  bool matchesTriggerWord(String text) {
    final lowerText = text.toLowerCase();
    return triggerWords.any((word) => lowerText.contains(word.toLowerCase()));
  }

  @override
  List<Object?> get props => [
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
}
