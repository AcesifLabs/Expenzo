import 'package:equatable/equatable.dart';
import 'source_type.dart';

export 'source_type.dart';

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
      id: _v(id, this.id),
      name: _v(name, this.name),
      triggerWords: _v(triggerWords, this.triggerWords),
      amountPattern: _v(amountPattern, this.amountPattern),
      datePattern: _v(datePattern, this.datePattern),
      categoryId: _v(categoryId, this.categoryId),
      sourceType: _v(sourceType, this.sourceType),
      isEnabled: _v(isEnabled, this.isEnabled),
      priority: _v(priority, this.priority),
      createdAt: _v(createdAt, this.createdAt),
      updatedAt: _v(updatedAt, this.updatedAt),
    );
  }

  bool matchesTriggerWord(String text) {
    final lowerText = text.toLowerCase();

    return triggerWords.any((word) => lowerText.contains(word.toLowerCase()));
  }

  static T _v<T>(T? value, T defaultValue) => value ?? defaultValue;
}
