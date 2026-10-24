import 'package:equatable/equatable.dart';

/// A server value and when it was fetched. [fromCache] is true when the
/// fetch failed and this is the copy saved on the device (ADR 0008: show
/// "last updated" when offline).
class Cached<T> extends Equatable {
  final T value;
  final DateTime fetchedAt;
  final bool fromCache;

  @override
  List<Object?> get props => [value, fetchedAt, fromCache];

  const Cached(this.value, {required this.fetchedAt, this.fromCache = false});

  Cached<T> asFromCache() =>
      Cached(value, fetchedAt: fetchedAt, fromCache: true);
}
