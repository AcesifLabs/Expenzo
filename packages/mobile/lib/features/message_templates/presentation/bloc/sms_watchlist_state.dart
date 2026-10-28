import 'package:equatable/equatable.dart';
import '../../domain/entities/watched_sender.dart';

sealed class SmsWatchlistState extends Equatable {
  @override
  List<Object?> get props => [];

  const SmsWatchlistState();
}

class SmsWatchlistLoading extends SmsWatchlistState {
  const SmsWatchlistLoading();
}

class SmsWatchlistReady extends SmsWatchlistState {
  final List<WatchedSender> senders;

  /// Set once when pausing or resuming a sender failed; the list stays.
  final String? toggleError;

  @override
  List<Object?> get props => [senders, toggleError];

  const SmsWatchlistReady({required this.senders, this.toggleError});
}

class SmsWatchlistError extends SmsWatchlistState {
  final String message;

  @override
  List<Object?> get props => [message];

  const SmsWatchlistError({required this.message});
}
