import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final String emoji;
  final String color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    int? id,
    String? name,
    String? emoji,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    emoji,
    color,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
