import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/scan_emails_usecase.dart';
import '../bloc/email_scanner_event.dart';
import '../bloc/email_scanner_state.dart';

class EmailScannerBloc extends Bloc<EmailScannerEvent, EmailScannerState> {
  final ScanEmailsUseCase scanEmailsUseCase;

  EmailScannerBloc({required this.scanEmailsUseCase})
    : super(EmailScannerInitial()) {
    on<StartEmailScan>(_onStartScan);
    on<ClearEmailResults>(_onClearResults);
  }

  Future<void> _onStartScan(
    StartEmailScan event,
    Emitter<EmailScannerState> emit,
  ) async {
    emit(const EmailScannerScanning(totalEmails: 0, processedEmails: 0));

    final result = await scanEmailsUseCase(
      ScanEmailsParams(maxResults: event.maxResults),
    );

    result.fold(
      (failure) => emit(EmailScannerError(message: failure.message)),
      (results) => emit(
        EmailScannerScanComplete(
          results: results,
          lastScanTimestamp: DateTime.now(),
        ),
      ),
    );
  }

  void _onClearResults(
    ClearEmailResults event,
    Emitter<EmailScannerState> emit,
  ) {
    emit(EmailScannerInitial());
  }
}
