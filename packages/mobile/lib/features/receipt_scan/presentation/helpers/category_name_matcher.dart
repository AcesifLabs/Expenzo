import 'package:expense_tracker/features/categories/domain/entities/category.dart';

/// Picks the best expense [Category] for a model-suggested category name.
Category? matchCategoryByName(String? hint, List<Category> categories) {
  if (hint == null || hint.trim().isEmpty || categories.isEmpty) return null;

  final normalized = _normalize(hint);

  for (final category in categories) {
    if (_normalize(category.name) == normalized) return category;
  }

  for (final category in categories) {
    final name = _normalize(category.name);
    if (name.contains(normalized) || normalized.contains(name)) {
      return category;
    }
  }

  final hintTokens = normalized
      .split(RegExp(r'\s+'))
      .where((t) => t.length > 2);
  Category? best;
  var bestScore = 0;
  for (final category in categories) {
    final name = _normalize(category.name);
    final score = hintTokens.where(name.contains).length;
    if (score > bestScore) {
      bestScore = score;
      best = category;
    }
  }

  return bestScore > 0 ? best : null;
}

String _normalize(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s&]'), '').trim();
