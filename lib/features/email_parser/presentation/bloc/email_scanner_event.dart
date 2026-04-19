import 'package:equatable/equatable.dart';

abstract class EmailScannerEvent extends Equatable {
  const EmailScannerEvent();

  @override
  List<Object?> get props => [];
}

class StartEmailScan extends EmailScannerEvent {
  final int? maxResults;

  const StartEmailScan({this.maxResults});

  @override
  List<Object?> get props => [maxResults];
}

class ClearEmailResults extends EmailScannerEvent {}
