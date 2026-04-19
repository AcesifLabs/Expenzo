import 'package:equatable/equatable.dart';

abstract class ContactSelectorEvent extends Equatable {
  const ContactSelectorEvent();

  @override
  List<Object?> get props => [];
}

class LoadContacts extends ContactSelectorEvent {}

class LoadMoreContacts extends ContactSelectorEvent {}
