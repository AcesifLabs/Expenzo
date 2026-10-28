import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/all_screens.dart';

void main() {
  test('every page in lib/features has a screen case', () {
    final pages = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.replaceFirst('lib/features/', ''))
        .where((path) => path.contains('/presentation/pages/'))
        .toSet();
    final covered = {
      for (final screen in allScreens) ?screen.page,
      ...pagesWithoutCase,
    };

    expect(pages.difference(covered), isEmpty, reason: 'pages without a case');
    expect(covered.difference(pages), isEmpty, reason: 'cases for no page');
  });

  test('screen names are unique', () {
    final names = [for (final screen in allScreens) screen.name];

    expect(names.toSet(), hasLength(names.length));
  });
}
