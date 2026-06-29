import 'package:equatable/equatable.dart';

abstract class ContactSelectorEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const ContactSelectorEvent();
}

class LoadContacts extends ContactSelectorEvent {}

class LoadMoreContacts extends ContactSelectorEvent {}
