import 'app_root_tab.dart';

String? coldStartLocation({required Uri current, required AppRootTab homeTab}) {
  if (current.toString().isEmpty || homeTab == AppRootTab.home) return null;
  if (current.path != AppRootTab.home.location) return null;
  if (current.queryParameters.containsKey(AppRootTab.queryKey)) return null;

  return homeTab.location;
}
