import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/services/file_share_service.dart';

import '../../domain/entities/export_request.dart';
import '../../domain/usecases/export_data.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportData exportData;
  final FileShareService shareService;

  ExportBloc({required this.exportData, required this.shareService})
    : super(const ExportState()) {
    on<ExportRangeSelected>(_onRangeSelected);
    on<ExportCustomRangePicked>(_onCustomRangePicked);
    on<ExportContentToggled>(_onContentToggled);
    on<ExportRequested>(_onRequested, transformer: droppable());
  }

  void _onRangeSelected(ExportRangeSelected event, Emitter<ExportState> emit) {
    if (state.isExporting || event.range == ExportRange.custom) return;
    emit(state.copyWith(range: event.range, status: ExportStatus.idle));
  }

  void _onCustomRangePicked(
    ExportCustomRangePicked event,
    Emitter<ExportState> emit,
  ) {
    if (state.isExporting || event.start.isAfter(event.end)) return;
    emit(
      state.copyWith(
        range: ExportRange.custom,
        customStart: event.start,
        customEnd: event.end,
        status: ExportStatus.idle,
      ),
    );
  }

  void _onContentToggled(
    ExportContentToggled event,
    Emitter<ExportState> emit,
  ) {
    if (state.isExporting) return;
    final contents = {...state.contents};
    if (event.included) {
      contents.add(event.content);
    } else {
      contents.remove(event.content);
    }
    emit(state.copyWith(contents: contents, status: ExportStatus.idle));
  }

  Future<void> _onRequested(
    ExportRequested event,
    Emitter<ExportState> emit,
  ) async {
    if (!state.canExport) return;
    emit(state.copyWith(status: ExportStatus.exporting));
    final result = await exportData(state.request);
    await result.fold(
      (failure) async => emit(
        failure is EmptyExportFailure
            ? state.copyWith(
                status: ExportStatus.empty,
                errorMessage: t.settings.export.emptyRange,
              )
            : state.copyWith(
                status: ExportStatus.failed,
                errorMessage: failureText(failure),
              ),
      ),
      (file) async {
        try {
          await shareService.shareFile(
            file.path,
            mimeType: file.mimeType,
            subject: t.settings.export.shareSubject,
          );
          emit(state.copyWith(status: ExportStatus.shared));
        } catch (e, s) {
          appLogger.error('Export share failed', e, s);
          emit(
            state.copyWith(
              status: ExportStatus.failed,
              errorMessage: t.common.errors.generic,
            ),
          );
        }
      },
    );
  }
}
