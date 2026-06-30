import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsLocalDatasource {
  /// Throws: [CacheException] if a database error occurs.
  Future<UserSettings> getSettings();
  Future<UserSettings> updateSettings(UserSettings settings);
}

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String _settingsKey = 'user_settings';

  SettingsLocalDatasourceImpl({required this.sharedPreferences});

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<UserSettings> getSettings() async {
    try {
      final jsonString = sharedPreferences.getString(_settingsKey);
      if (jsonString == null) {
        final now = DateTime.now().toUtc();
        final defaultSettings = UserSettings(
          currencySymbol: '\$',
          emailFetchLimit: 100,
          notificationsEnabled: true,
          theme: 'system',
          createdAt: now,
          updatedAt: now,
        );

        return await updateSettings(defaultSettings);
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return _mapFromJson(json);
    } catch (e, s) {
      appLogger.error('Settings local datasource error', e, s);
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<UserSettings> updateSettings(UserSettings settings) async {
    try {
      final json = _mapToJson(settings);
      await sharedPreferences.setString(_settingsKey, jsonEncode(json));

      return settings;
    } catch (e, s) {
      appLogger.error('Settings local datasource error', e, s);
      throw CacheException(message: e.toString());
    }
  }

  Map<String, dynamic> _mapToJson(UserSettings settings) {
    return {
      'id': settings.id,
      'currencySymbol': settings.currencySymbol,
      'emailFetchLimit': settings.emailFetchLimit,
      'notificationsEnabled': settings.notificationsEnabled,
      'theme': settings.theme,
      'createdAt': settings.createdAt.toIso8601String(),
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }

  UserSettings _mapFromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as int?,
      currencySymbol: json['currencySymbol'] as String,
      emailFetchLimit: json['emailFetchLimit'] as int,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      theme: json['theme'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
