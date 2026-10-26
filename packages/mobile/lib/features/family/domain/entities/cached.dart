import 'package:equatable/equatable.dart';

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
