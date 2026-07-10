import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';

/// Creates a [Category] for tests. All params optional with deterministic defaults.
Category makeCategory({
  String? id,
  String? name,
  String? emoji,
  String? color,
  bool? isDefault,
  RecordType? type,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Category(
    id: id ?? 'cat-0001',
    name: name ?? 'Food',
    emoji: emoji ?? '🍔',
    color: color ?? '#FF5722',
    isDefault: isDefault ?? false,
    type: type ?? RecordType.expense,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
    updatedAt: updatedAt ?? DateTime(2024, 1, 1),
  );
}
