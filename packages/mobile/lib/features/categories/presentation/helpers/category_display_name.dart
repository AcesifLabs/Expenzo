import 'package:expense_tracker/core/utils/category_display_name.dart';

import '../../domain/entities/category.dart';

export 'package:expense_tracker/core/utils/category_display_name.dart';

extension CategoryDisplayName on Category {
  String get displayName => categoryDisplayName(id: id, name: name);
}
