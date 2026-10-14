import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/scaled_text_scaler.dart';

void main() {
  test('scale multiplies the base scaler', () {
    const scaler = ScaledTextScaler(TextScaler.linear(1.5), 1.15);

    expect(scaler.scale(14), closeTo(14 * 1.5 * 1.15, 1e-9));
  });

  test('scalers with the same base and factor are equal', () {
    const a = ScaledTextScaler(TextScaler.linear(1.2), 1.3);
    const b = ScaledTextScaler(TextScaler.linear(1.2), 1.3);
    const c = ScaledTextScaler(TextScaler.linear(1.2), 0.9);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
  });

  test('a clamp caps the product', () {
    final scaler = const ScaledTextScaler(
      TextScaler.linear(1.8),
      1.3,
    ).clamp(maxScaleFactor: 2);

    expect(scaler.scale(10), 20);
  });
}
