import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Icon rule from DESIGN.md: Phosphor Regular everywhere, Fill only for the
/// selected tab in the app shell.
const _fillAllowlist = {'shared/presentation/widgets/app_shell.dart'};

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

  test('only the Regular Phosphor weight, Fill only for the selected tab', () {
    expect(
      _offenders(RegExp(r'Picons(Light|Bold|Thin|Duotone)\.')),
      isEmpty,
      reason: 'Use PiconsRegular instead.',
    );
    expect(
      _offenders(RegExp(r'PiconsFill\.'), allow: _fillAllowlist),
      isEmpty,
      reason: 'PiconsFill is only for the selected tab.',
    );
  });
}
