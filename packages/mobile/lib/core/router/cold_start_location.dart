import 'app_root_tab.dart';

/// Where to send the app when settings first load, or null to stay.
///
/// Only a bare `/` (no `tab` query) is redirected, so deep links, `/?tab=…`
/// links and the onboarding redirect (SAAP-74, at `/onboarding`) win. There
/// is no auth gate on `/`, so a signed-out start opens the same tab.
String? coldStartLocation({required Uri current, required AppRootTab homeTab}) {
  if (current.toString().isEmpty || homeTab == AppRootTab.home) return null;
  if (current.path != AppRootTab.home.location) return null;
  if (current.queryParameters.containsKey(AppRootTab.queryKey)) return null;

  return homeTab.location;
}
