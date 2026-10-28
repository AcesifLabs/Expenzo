import 'settings_route.dart';

enum HelpRoute {
  faq('faq'),
  rate('rate'),
  about('about');

  final String path;

  const HelpRoute(this.path);

  String get location => '${SettingsRoute.help.location}/$path';
}
