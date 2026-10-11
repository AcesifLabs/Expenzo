import 'strings.g.dart';

/// Registers plural rules slang doesn't ship with. Call once at start-up,
/// before any plural string is read.
void registerPluralResolvers() {
  // CLDR Bengali: "one" for 0 and 1 (i = 0 or n = 1), "other" otherwise.
  LocaleSettings.setPluralResolverSync(
    locale: AppLocale.bn,
    cardinalResolver: (n, {zero, one, two, few, many, other}) =>
        ((n.truncate() == 0 || n == 1) ? one : null) ?? other ?? '',
    ordinalResolver: (n, {zero, one, two, few, many, other}) => other ?? '',
  );
}
