import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final int? id;
  final String currencySymbol;
  final int emailFetchLimit;
  final bool notificationsEnabled;
  final String theme;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    this.id,
    required this.currencySymbol,
    required this.emailFetchLimit,
    required this.notificationsEnabled,
    required this.theme,
    required this.createdAt,
    required this.updatedAt,
  });

  UserSettings copyWith({
    int? id,
    String? currencySymbol,
    int? emailFetchLimit,
    bool? notificationsEnabled,
    String? theme,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      emailFetchLimit: emailFetchLimit ?? this.emailFetchLimit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    currencySymbol,
    emailFetchLimit,
    notificationsEnabled,
    theme,
    createdAt,
    updatedAt,
  ];
}
