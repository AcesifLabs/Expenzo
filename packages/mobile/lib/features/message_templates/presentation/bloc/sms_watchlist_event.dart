import 'package:equatable/equatable.dart';
import '../../domain/entities/watched_sender.dart';

sealed class SmsWatchlistEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SmsWatchlistEvent();
}

class SmsWatchlistLoadRequested extends SmsWatchlistEvent {
  const SmsWatchlistLoadRequested();
}

class SmsWatchlistSenderToggled extends SmsWatchlistEvent {
  final WatchedSender sender;
  final bool isActive;

  @override
  List<Object?> get props => [sender, isActive];

  const SmsWatchlistSenderToggled({
    required this.sender,
    required this.isActive,
  });
}
