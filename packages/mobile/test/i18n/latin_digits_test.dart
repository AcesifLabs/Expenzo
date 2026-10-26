import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bangla translations use Latin digits', () {
    final banglaDigit = RegExp('[০-৯]');
    final offenders = [
      for (final file in Directory('lib/i18n').listSync(recursive: true))
        if (file is File && file.path.endsWith('_bn.i18n.json'))
          for (final (index, line) in file.readAsLinesSync().indexed)
            if (banglaDigit.hasMatch(line)) '${file.path}:${index + 1}',
    ];

    expect(offenders, isEmpty);
  });
}
