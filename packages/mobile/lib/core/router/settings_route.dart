enum SettingsRoute {
  profile('profile'),
  family('family'),
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
  smsWatchlist('sms-watchlist'),
  recurring('recurring'),
  sync('sync'),
  export('export'),
  deleteData('delete-data'),
  help('help');

  final String path;

  static const rootPath = 'settings';
  static const rootLocation = '/$rootPath';

  const SettingsRoute(this.path);

  String get location => '$rootLocation/$path';
}
