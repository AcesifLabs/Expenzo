import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'failures.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class Params extends Equatable {
  const Params();
}
