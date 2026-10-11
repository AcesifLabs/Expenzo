import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final int? id;

  /// ISO 4217 code, see `CurrencyConfig`.
  final String currencyCode;
  final int emailFetchLimit;
  final bool notificationsEnabled;
  final String theme;

  /// 'system' follows the device language; otherwise a locale code ('en', 'bn').
  final String languageCode;

  /// True once the user dismissed the Home "Set up auto-import" card.
  final bool autoImportPromptDismissed;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    currencyCode,
    emailFetchLimit,
    notificationsEnabled,
    theme,
    languageCode,
    autoImportPromptDismissed,
    createdAt,
    updatedAt,
  ];

  const UserSettings({
    this.id,
    required this.currencyCode,
    required this.emailFetchLimit,
    required this.notificationsEnabled,
    required this.theme,
    this.languageCode = 'system',
    this.autoImportPromptDismissed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettings copyWith({
    int? id,
    String? currencyCode,
    int? emailFetchLimit,
    bool? notificationsEnabled,
    String? theme,
    String? languageCode,
    bool? autoImportPromptDismissed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      emailFetchLimit: emailFetchLimit ?? this.emailFetchLimit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      autoImportPromptDismissed:
          autoImportPromptDismissed ?? this.autoImportPromptDismissed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
