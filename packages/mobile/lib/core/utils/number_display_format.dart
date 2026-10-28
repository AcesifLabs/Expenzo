import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';

class NumberDisplayFormat extends Equatable {
  static const allowedDecimalPlaces = [0, 2];
  static const defaultDecimalPlaces = 2;
  static const defaultGrouping = DigitGrouping.comma;

  static const standard = NumberDisplayFormat(
    decimalPlaces: defaultDecimalPlaces,
    grouping: defaultGrouping,
  );

  final int decimalPlaces;
  final DigitGrouping grouping;

  @override
  List<Object?> get props => [decimalPlaces, grouping];

  const NumberDisplayFormat({
    required this.decimalPlaces,
    required this.grouping,
  });
}
