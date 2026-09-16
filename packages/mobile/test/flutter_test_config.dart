import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests default to [TargetPlatform.android], which loads the
/// `ink_sparkle.frag` runtime shader on button taps. After a Flutter SDK or
/// engine upgrade, a stale build cache can make that shader fail to decode and
/// flake widget tests. Use a platform that picks [InkRipple] instead.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  await testMain();
  debugDefaultTargetPlatformOverride = null;
}
