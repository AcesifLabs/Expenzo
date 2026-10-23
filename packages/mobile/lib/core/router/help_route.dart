import 'settings_route.dart';

/// Screens pushed from Help & Support, as children of `/settings/help`.
///
/// Both the route tree (`app_routes.dart`) and `context.push` read paths
/// from here, so a rename can't leave a stale link.
enum HelpRoute {
  faq('faq'),
  rate('rate'),
  about('about');

  /// The child segment under [SettingsRoute.help].
  final String path;

  const HelpRoute(this.path);

  String get location => '${SettingsRoute.help.location}/$path';
}
