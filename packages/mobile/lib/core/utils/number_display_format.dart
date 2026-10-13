import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';

/// The user's Number format setting as `CurrencyFormatter` applies it.
class NumberDisplayFormat extends Equatable {
  /// The choices on the Number format screen; anything else stored reads as
  /// [defaultDecimalPlaces].
  static const allowedDecimalPlaces = [0, 2];
  static const defaultDecimalPlaces = 2;
  static const defaultGrouping = DigitGrouping.comma;

  static const standard = NumberDisplayFormat(
    decimalPlaces: defaultDecimalPlaces,
    grouping: defaultGrouping,
  );

  /// Upper bound on decimals shown; a currency never gains decimals from it.
  final int decimalPlaces;
  final DigitGrouping grouping;

  @override
  List<Object?> get props => [decimalPlaces, grouping];

  const NumberDisplayFormat({
    required this.decimalPlaces,
    required this.grouping,
  });
}
