import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_transaction.dart';

abstract class RecurringEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const RecurringEvent();
}

class LoadRecurring extends RecurringEvent {}

class CreateRecurring extends RecurringEvent {
  final RecurringTransaction recurring;

  @override
  List<Object?> get props => [recurring];

  const CreateRecurring(this.recurring);
}

class UpdateRecurring extends RecurringEvent {
  final RecurringTransaction recurring;

  @override
  List<Object?> get props => [recurring];

  const UpdateRecurring(this.recurring);
}

class DeleteRecurring extends RecurringEvent {
  final String id;

  @override
  List<Object?> get props => [id];

  const DeleteRecurring(this.id);
}

class ProcessRecurring extends RecurringEvent {
  const ProcessRecurring();
}
