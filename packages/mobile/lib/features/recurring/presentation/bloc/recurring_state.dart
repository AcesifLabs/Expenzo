import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_transaction.dart';

sealed class RecurringState extends Equatable {
  @override
  List<Object?> get props => [];

  const RecurringState();
}

class RecurringInitial extends RecurringState {
  const RecurringInitial();
}

class RecurringLoading extends RecurringState {
  const RecurringLoading();
}

class RecurringLoaded extends RecurringState {
  final List<RecurringTransaction> recurringList;

  @override
  List<Object?> get props => [recurringList];

  const RecurringLoaded(this.recurringList);

  RecurringLoaded copyWith({List<RecurringTransaction>? recurringList}) {
    return RecurringLoaded(recurringList ?? this.recurringList);
  }
}

class RecurringError extends RecurringState {
  final String message;

  @override
  List<Object?> get props => [message];

  const RecurringError(this.message);
}

class RecurringOperationSuccess extends RecurringState {
  @override
  List<Object?> get props => [];

  const RecurringOperationSuccess();
}
