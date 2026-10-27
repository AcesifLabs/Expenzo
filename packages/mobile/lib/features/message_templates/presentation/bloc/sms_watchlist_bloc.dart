import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../../domain/usecases/get_sms_watchlist.dart';
import '../../domain/usecases/save_message_source.dart';
import 'sms_watchlist_event.dart';
import 'sms_watchlist_state.dart';

class SmsWatchlistBloc extends Bloc<SmsWatchlistEvent, SmsWatchlistState> {
  final GetSmsWatchlist getSmsWatchlist;
  final SaveMessageSource saveMessageSource;

  SmsWatchlistBloc({
    required this.getSmsWatchlist,
    required this.saveMessageSource,
  }) : super(const SmsWatchlistLoading()) {
    on<SmsWatchlistLoadRequested>(_onLoaded, transformer: restartable());
    on<SmsWatchlistSenderToggled>(_onToggled, transformer: sequential());
  }

  Future<void> _onLoaded(
    SmsWatchlistLoadRequested event,
    Emitter<SmsWatchlistState> emit,
  ) async {
    final result = await getSmsWatchlist(NoParams());
    result.fold(
      (failure) => emit(SmsWatchlistError(message: failureText(failure))),
      (senders) => emit(SmsWatchlistReady(senders: senders)),
    );
  }

  Future<void> _onToggled(
    SmsWatchlistSenderToggled event,
    Emitter<SmsWatchlistState> emit,
  ) async {
    final source = event.sender.source.copyWith(
      isMonitored: event.isActive,
      updatedAt: DateTime.now(),
    );
    final result = await saveMessageSource(source);

    final current = state;
    await result.fold(
      (failure) async => emit(
        current is SmsWatchlistReady
            ? SmsWatchlistReady(
                senders: current.senders,
                toggleError: failureText(failure),
              )
            : SmsWatchlistError(message: failureText(failure)),
      ),
      (_) => _onLoaded(const SmsWatchlistLoadRequested(), emit),
    );
  }
}
