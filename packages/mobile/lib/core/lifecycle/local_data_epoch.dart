import 'package:flutter/foundation.dart';

/// Bumped when local data is wiped or replaced, so root screens rebuild from
/// scratch.
class LocalDataEpoch extends ValueNotifier<int> {
  LocalDataEpoch() : super(0);

  void bump() => value++;
}
