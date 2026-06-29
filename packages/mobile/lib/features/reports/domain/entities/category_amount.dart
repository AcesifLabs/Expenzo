import 'package:equatable/equatable.dart';

class CategoryAmount extends Equatable {
  final String categoryId;
  final String categoryName;
  final String emoji;
  final double amount;
  final double percentage;

  const CategoryAmount({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    emoji,
    amount,
    percentage,
  ];
}
