import 'package:equatable/equatable.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

abstract class SmsScannerEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SmsScannerEvent();
}

class StartScan extends SmsScannerEvent {
  final DateTime? since;
  final bool filterDuplicates;

  @override
  List<Object?> get props => [since, filterDuplicates];

  const StartScan({this.since, this.filterDuplicates = false});
}

class LoadMoreScanResults extends SmsScannerEvent {
  final bool filterDuplicates;

  @override
  List<Object?> get props => [filterDuplicates];

  const LoadMoreScanResults({this.filterDuplicates = false});
}

class ClearResults extends SmsScannerEvent {}

class ToggleSelection extends SmsScannerEvent {
  final String transactionId;

  @override
  List<Object?> get props => [transactionId];

  const ToggleSelection({required this.transactionId});
}

class SelectAll extends SmsScannerEvent {}

class DeselectAll extends SmsScannerEvent {}

class CreateSelectedExpenses extends SmsScannerEvent {
  final List<ParsedTransaction> transactions;

  @override
  List<Object?> get props => [transactions];

  const CreateSelectedExpenses({required this.transactions});
}
