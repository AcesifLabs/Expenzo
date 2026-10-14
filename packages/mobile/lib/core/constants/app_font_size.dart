import 'package:expense_tracker/i18n/strings.g.dart';

/// The Font size setting: a factor on the device's own text scale
/// (Settings > Font size). The product is capped at
/// `AppConstants.maxTextScale`.
enum AppFontSize {
  small(0.9),
  medium(1.0),
  large(1.15),
  extraLarge(1.3);

  static const defaultSize = medium;

  final double scale;

  const AppFontSize(this.scale);

  String get displayName {
    final labels = t.enums.fontSize;

    return switch (this) {
      AppFontSize.small => labels.small.title,
      AppFontSize.medium => labels.medium.title,
      AppFontSize.large => labels.large.title,
      AppFontSize.extraLarge => labels.extraLarge.title,
    };
  }

  String get description {
    final labels = t.enums.fontSize;

    return switch (this) {
      AppFontSize.small => labels.small.description,
      AppFontSize.medium => labels.medium.description,
      AppFontSize.large => labels.large.description,
      AppFontSize.extraLarge => labels.extraLarge.description,
    };
  }

  /// The value stored under [name], or null for a missing or unknown one.
  static AppFontSize? fromName(String? name) {
    for (final size in values) {
      if (size.name == name) return size;
    }

    return null;
  }
}
