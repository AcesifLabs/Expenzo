import 'package:equatable/equatable.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

abstract class SmsScannerEvent extends Equatable {
  const SmsScannerEvent();

  @override
  List<Object?> get props => [];
}

class StartScan extends SmsScannerEvent {
  final DateTime? since;
  final bool filterDuplicates;

  const StartScan({this.since, this.filterDuplicates = false});

  @override
  List<Object?> get props => [since, filterDuplicates];
}

class LoadMoreScanResults extends SmsScannerEvent {
  final bool filterDuplicates;

  const LoadMoreScanResults({this.filterDuplicates = false});

  @override
  List<Object?> get props => [filterDuplicates];
}

class ClearResults extends SmsScannerEvent {}

class ToggleSelection extends SmsScannerEvent {
  final String transactionId;

  const ToggleSelection({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class SelectAll extends SmsScannerEvent {}

class DeselectAll extends SmsScannerEvent {}

class CreateSelectedExpenses extends SmsScannerEvent {
  final List<ParsedTransaction> transactions;
  const CreateSelectedExpenses({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}
