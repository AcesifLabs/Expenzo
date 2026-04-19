import 'package:equatable/equatable.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

abstract class EmailScannerState extends Equatable {
  const EmailScannerState();

  @override
  List<Object?> get props => [];
}

class EmailScannerInitial extends EmailScannerState {}

class EmailScannerScanning extends EmailScannerState {
  final int totalEmails;
  final int processedEmails;
  final DateTime? scanStartTime;

  const EmailScannerScanning({
    required this.totalEmails,
    required this.processedEmails,
    this.scanStartTime,
  });

  double get progress => totalEmails > 0 ? processedEmails / totalEmails : 0;

  @override
  List<Object?> get props => [totalEmails, processedEmails, scanStartTime];
}

class EmailScannerScanComplete extends EmailScannerState {
  final List<ParsedTransaction> results;
  final DateTime lastScanTimestamp;

  const EmailScannerScanComplete({
    required this.results,
    required this.lastScanTimestamp,
  });

  @override
  List<Object?> get props => [results, lastScanTimestamp];
}

class EmailScannerError extends EmailScannerState {
  final String message;

  const EmailScannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
