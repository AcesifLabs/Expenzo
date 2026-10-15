/// Screens pushed from the Settings list, as children of `/settings`.
///
/// Both the route tree (`app_routes.dart`) and `context.push` read paths
/// from here, so a rename can't leave a stale link.
enum SettingsRoute {
  appearance('appearance'),
  currency('currency'),
  language('language'),
  numberFormat('number-format'),
  fontSize('font-size'),
  calendar('calendar'),
  homePage('home-page'),
  notifications('notifications'),
  categories('categories'),
  autoImport('auto-import'),
  matchingRules('matching-rules'),
  recurring('recurring'),
  export('export'),
  deleteData('delete-data');

  /// The child segment under [rootPath].
  final String path;

  /// The Settings list's own segment under `/`.
  static const rootPath = 'settings';
  static const rootLocation = '/$rootPath';

  const SettingsRoute(this.path);

  String get location => '$rootLocation/$path';
}
