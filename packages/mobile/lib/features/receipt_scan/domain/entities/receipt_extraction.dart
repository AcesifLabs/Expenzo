import 'package:equatable/equatable.dart';

/// Structured values proposed from a receipt image for the New Transaction sheet.
class ReceiptExtraction extends Equatable {
  final double amount;
  final String description;
  final DateTime? date;
  final String? categoryName;

  @override
  List<Object?> get props => [amount, description, date, categoryName];

  const ReceiptExtraction({
    required this.amount,
    required this.description,
    this.date,
    this.categoryName,
  });
}
