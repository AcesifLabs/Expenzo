import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsRemoteDatasource {
  Future<UserSettings> syncSettings(UserSettings settings);
  Future<void> deleteAccount();
}

class SettingsRemoteDatasourceImpl implements SettingsRemoteDatasource {
  final http.Client client;
  final String baseUrl;

  SettingsRemoteDatasourceImpl({
    required this.client,
    this.baseUrl = 'https://api.expenzo.com',
  });

  @override
  Future<UserSettings> syncSettings(UserSettings settings) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/settings/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currencySymbol': settings.currencySymbol,
          'emailFetchLimit': settings.emailFetchLimit,
          'notificationsEnabled': settings.notificationsEnabled,
          'theme': settings.theme,
        }),
      );
      if (response.statusCode == 200) {
        return settings;
      }
      throw ServerException(
        message: 'Failed to sync settings',
        statusCode: response.statusCode,
      );
    } on http.ClientException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/account'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to delete account',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
