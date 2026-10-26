import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/api/api_constants.dart';

abstract final class AppConfig {
  static const feedbackEmail = 'asifzubayerpalak@gmail.com';

  static Uri get privacyPolicyUri =>
      publicPageUri(ApiConstants.baseUrl, 'privacy');

  static Uri get termsOfServiceUri =>
      publicPageUri(ApiConstants.baseUrl, 'terms');

  @visibleForTesting
  static Uri publicPageUri(String apiBaseUrl, String slug) {
    final base = Uri.parse(apiBaseUrl);

    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/$slug',
    );
  }
}
