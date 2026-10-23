import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/api/api_constants.dart';

/// App-wide constants that differ per release.
abstract final class AppConfig {
  /// Where "Send feedback" and Contact support emails go.
  static const feedbackEmail = 'asifzubayerpalak@gmail.com';

  /// The privacy policy page served by the backend (`public/privacy.html`).
  static Uri get privacyPolicyUri =>
      publicPageUri(ApiConstants.baseUrl, 'privacy');

  /// The terms page served by the backend (`public/terms.html`).
  static Uri get termsOfServiceUri =>
      publicPageUri(ApiConstants.baseUrl, 'terms');

  /// [apiBaseUrl] with its path replaced by `/[slug]`: the static pages live
  /// at the site root, outside the `api` prefix.
  @visibleForTesting
  static Uri publicPageUri(String apiBaseUrl, String slug) {
    final base = Uri.parse(apiBaseUrl);

    // A new Uri, not base.replace(): replace keeps a query it is not given.
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/$slug',
    );
  }
}
