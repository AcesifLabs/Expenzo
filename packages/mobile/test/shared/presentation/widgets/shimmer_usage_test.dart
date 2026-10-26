import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every file drawing shimmer shapes wraps them in a shimmer', () {
    final shape = RegExp(r'ShimmerBox\.(rectangle|circle|textLine)\(');
    final unwrapped = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File && file.path.endsWith('.dart'))
          if (file.readAsStringSync() case final source
              when shape.hasMatch(source) &&
                  !source.contains('ShimmerBox(') &&
                  !source.contains('ShimmerList('))
            file.path,
    ];

    expect(unwrapped, isEmpty);
  });
}
