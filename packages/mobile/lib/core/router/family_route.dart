import 'settings_route.dart';

enum FamilyRoute {
  join('join'),
  invite('invite'),
  members('members');

  final String path;

  const FamilyRoute(this.path);

  String get location => '${SettingsRoute.family.location}/$path';
}
