import 'settings_route.dart';

/// Screens pushed from the Family group page, as children of
/// `/settings/family`.
///
/// Both the route tree (`app_routes.dart`) and `context.push` read paths
/// from here, so a rename can't leave a stale link.
enum FamilyRoute {
  join('join'),
  invite('invite'),
  members('members');

  /// The child segment under [SettingsRoute.family].
  final String path;

  const FamilyRoute(this.path);

  String get location => '${SettingsRoute.family.location}/$path';
}
