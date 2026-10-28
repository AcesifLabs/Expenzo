import 'strings.g.dart';

void registerPluralResolvers() {
  LocaleSettings.setPluralResolverSync(
    locale: AppLocale.bn,
    cardinalResolver: (n, {zero, one, two, few, many, other}) =>
        ((n.truncate() == 0 || n == 1) ? one : null) ?? other ?? '',
    ordinalResolver: (n, {zero, one, two, few, many, other}) => other ?? '',
  );
}
