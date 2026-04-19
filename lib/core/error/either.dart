import 'package:dartz/dartz.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right;

extension EitherExtension<L, R> on Either<L, R> {
  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) {
    return fold(onLeft, onRight);
  }

  Either<L, T> map<T>(T Function(R r) f) {
    return map(f);
  }

  Either<T, R> mapLeft<T>(T Function(L l) f) {
    return mapLeft(f);
  }

  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) {
    return flatMap(f);
  }

  R getOrElse(R Function() defaultValue) {
    return getOrElse(defaultValue);
  }

  R? getOrNull() {
    return getOrNull();
  }

  bool get isLeft => fold((_) => true, (_) => false);

  bool get isRight => fold((_) => false, (_) => true);
}
