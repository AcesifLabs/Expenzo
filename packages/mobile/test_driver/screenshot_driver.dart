import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    File('assets/images/onboarding/$name.png').writeAsBytesSync(bytes);

    return true;
  },
);
