import 'package:flutter/painting.dart';

/// The device's text scaler times the user's Font size factor (SAAP-66).
///
/// Multiplies [base] rather than replacing it, so the device's own curve
/// (Android 14 scales large text non-linearly) is kept.
class ScaledTextScaler extends TextScaler {
  final TextScaler base;
  final double factor;

  @override
  // Must be implemented; only legacy readers use it.
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  // Equal scalers compare equal, so MediaQuery doesn't notify dependents
  // when nothing changed.
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
