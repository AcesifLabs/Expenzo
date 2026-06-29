import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_transaction.dart';

abstract class RecurringState extends Equatable {
  @override
  List<Object?> get props => [];

  const RecurringState();
}

class RecurringInitial extends RecurringState {}

class RecurringLoading extends RecurringState {}

class RecurringLoaded extends RecurringState {
  final List<RecurringTransaction> recurringList;

  @override
  List<Object?> get props => [recurringList];

  const RecurringLoaded(this.recurringList);
}

class RecurringError extends RecurringState {
  final String message;

  @override
  List<Object?> get props => [message];

  const RecurringError(this.message);
}

class RecurringOperationSuccess extends RecurringState {
  final String message;

  @override
  List<Object?> get props => [message];

  const RecurringOperationSuccess(this.message);
}
