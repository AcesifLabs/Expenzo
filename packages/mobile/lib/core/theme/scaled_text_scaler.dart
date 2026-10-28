import 'package:flutter/painting.dart';

class ScaledTextScaler extends TextScaler {
  final TextScaler base;
  final double factor;

  @override
  double get textScaleFactor => base.scale(1) * factor;

  @override
  int get hashCode => Object.hash(base, factor);

  const ScaledTextScaler(this.base, this.factor);

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  bool operator ==(Object other) {
    return other is ScaledTextScaler &&
        other.base == base &&
        other.factor == factor;
  }
}
