import 'package:equatable/equatable.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

import 'sms_scanner_view_mode.dart';

abstract class SmsScannerEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SmsScannerEvent();
}

class StartScan extends SmsScannerEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool filterDuplicates;

  @override
  List<Object?> get props => [startDate, endDate, filterDuplicates];

  const StartScan({
    this.startDate,
    this.endDate,
    this.filterDuplicates = false,
  });
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

class SelectSenderGroup extends SmsScannerEvent {
  final String senderKey;

  @override
  List<Object?> get props => [senderKey];

  const SelectSenderGroup({required this.senderKey});
}

class DeselectSenderGroup extends SmsScannerEvent {
  final String senderKey;

  @override
  List<Object?> get props => [senderKey];

  const DeselectSenderGroup({required this.senderKey});
}

class SetViewMode extends SmsScannerEvent {
  final SmsScannerViewMode viewMode;

  @override
  List<Object?> get props => [viewMode];

  const SetViewMode({required this.viewMode});
}

class CreateSelectedExpenses extends SmsScannerEvent {
  final List<ParsedTransaction> transactions;

  @override
  List<Object?> get props => [transactions];

  const CreateSelectedExpenses({required this.transactions});
}
