import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_transaction.dart';

abstract class RecurringState extends Equatable {
  const RecurringState();

  @override
  List<Object?> get props => [];
}

class RecurringInitial extends RecurringState {}

class RecurringLoading extends RecurringState {}

class RecurringLoaded extends RecurringState {
  final List<RecurringTransaction> recurringList;

  const RecurringLoaded(this.recurringList);

  @override
  List<Object?> get props => [recurringList];
}

class RecurringError extends RecurringState {
  final String message;

  const RecurringError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecurringOperationSuccess extends RecurringState {
  final String message;

  const RecurringOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
