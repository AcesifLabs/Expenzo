import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Icon rule from DESIGN.md: Phosphor Regular everywhere, Fill only for a
/// selected state. `AppRootTab.selectedIcon` holds the selected tab's Fill
/// icons, and only the shell reads it; Rate the app fills the chosen stars.
const _fillAllowlist = {
  'shared/presentation/widgets/app_shell.dart',
  'core/router/app_root_tab.dart',
  'features/support/presentation/pages/rate_app_page.dart',
};

Iterable<(String, String)> _libFiles() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    yield (entity.path.substring('lib/'.length), entity.readAsStringSync());
  }
}

List<String> _offenders(RegExp pattern, {Set<String> allow = const {}}) => [
  for (final (path, source) in _libFiles())
    if (!allow.contains(path))
      for (final match in pattern.allMatches(source))
        '$path:${source.substring(0, match.start).split('\n').length}',
];

void main() {
  test('no Material icons', () {
    expect(
      _offenders(RegExp(r'(?<![A-Za-z])Icons\.\w')),
      isEmpty,
      reason: 'Use PiconsRegular instead.',
    );
  });

  test('only the Regular Phosphor weight, Fill only for a selected state', () {
    expect(
      _offenders(RegExp(r'Picons(Light|Bold|Thin|Duotone)\.')),
      isEmpty,
      reason: 'Use PiconsRegular instead.',
    );
    expect(
      _offenders(RegExp(r'PiconsFill\.'), allow: _fillAllowlist),
      isEmpty,
      reason: 'PiconsFill is only for a selected state (tab, rating stars).',
    );
  });
}
