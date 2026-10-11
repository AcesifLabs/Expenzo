/// Root screens hosted as tabs inside the app shell at `/`.
///
/// The selected tab lives in the `tab` query parameter so any screen can
/// navigate straight to a root screen with `context.go(tab.location)`.
enum AppRootTab {
  home,
  activity,
  budgets,
  reports;

  static const queryKey = 'tab';

  String get location => this == home ? '/' : '/?$queryKey=$name';

  static AppRootTab fromUri(Uri uri) =>
      values.asNameMap()[uri.queryParameters[queryKey]] ?? home;
}
