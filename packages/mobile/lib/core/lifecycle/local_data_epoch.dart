import 'package:flutter/foundation.dart';

class LocalDataEpoch extends ValueNotifier<int> {
  LocalDataEpoch() : super(0);

  void bump() => value++;
}
