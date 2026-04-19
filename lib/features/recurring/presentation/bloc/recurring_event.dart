import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_transaction.dart';

abstract class RecurringEvent extends Equatable {
  const RecurringEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecurring extends RecurringEvent {}

class CreateRecurring extends RecurringEvent {
  final RecurringTransaction recurring;

  const CreateRecurring(this.recurring);

  @override
  List<Object?> get props => [recurring];
}

class UpdateRecurring extends RecurringEvent {
  final RecurringTransaction recurring;

  const UpdateRecurring(this.recurring);

  @override
  List<Object?> get props => [recurring];
}

class DeleteRecurring extends RecurringEvent {
  final String id;

  const DeleteRecurring(this.id);

  @override
  List<Object?> get props => [id];
}

class ProcessRecurring extends RecurringEvent {
  const ProcessRecurring();
}
