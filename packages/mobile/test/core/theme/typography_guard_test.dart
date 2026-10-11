import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps typography inside the theme (docs/adr/0005).
///
/// Widgets get fonts and sizes from `Theme.of(context).textTheme` or
/// `AppTypography`, never from inline values.
const _fontFamilyAllowlist = {
  // Code blocks and error reference IDs.
  'features/ai_assistant/presentation/widgets/chat_bubble.dart',
  'shared/presentation/widgets/app_error_fallback.dart',
};

Iterable<(String, String)> _libFiles() sync* {
  final lib = Directory('lib');
  for (final entity in lib.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.substring('lib/'.length);
    if (path.startsWith('core/theme/')) continue;
    yield (path, entity.readAsStringSync());
  }
}

void main() {
  test('no inline font families outside the theme', () {
    final offenders = [
      for (final (path, source) in _libFiles())
        if (source.contains('fontFamily:') &&
            !_fontFamilyAllowlist.contains(path))
          path,
    ];

    expect(offenders, isEmpty, reason: 'Use the theme text styles instead.');
  });

  test('no inline font sizes outside the theme', () {
    final offenders = [
      for (final (path, source) in _libFiles())
        for (final match in RegExp(r'fontSize:\s*\d').allMatches(source))
          '$path:${source.substring(0, match.start).split('\n').length}',
    ];

    expect(offenders, isEmpty, reason: 'Use the theme text styles instead.');
  });

  test('no inline corner radii outside the theme', () {
    final offenders = [
      for (final (path, source) in _libFiles())
        for (final match in RegExp(r'Radius\.circular\(\d').allMatches(source))
          '$path:${source.substring(0, match.start).split('\n').length}',
    ];

    expect(offenders, isEmpty, reason: 'Use the AppSpacing radius tokens.');
  });
}
