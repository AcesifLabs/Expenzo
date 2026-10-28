import 'package:equatable/equatable.dart';

import 'message_source.dart';

/// A sender on the SMS Watchlist: a message source with at least one SMS
/// Format. Paused when its source is not monitored.
class WatchedSender extends Equatable {
  final MessageSource source;
  final int formatCount;

  bool get isActive => source.isMonitored;

  @override
  List<Object?> get props => [source, formatCount];

  const WatchedSender({required this.source, required this.formatCount});
}
