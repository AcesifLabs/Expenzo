import 'package:equatable/equatable.dart';

class DateAmount extends Equatable {
  final DateTime date;
  final double amount;

  const DateAmount({required this.date, required this.amount});

  @override
  List<Object?> get props => [date, amount];
}
