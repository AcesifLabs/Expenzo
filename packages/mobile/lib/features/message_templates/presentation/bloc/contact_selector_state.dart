import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/source_types.dart';

class DeviceContact extends Equatable {
  final String address;
  final String displayName;
  final String lastMessage;
  final DateTime lastMessageDate;
  final ExpenseSource sourceType;

  const DeviceContact({
    required this.address,
    required this.displayName,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.sourceType,
  });

  @override
  List<Object?> get props => [
    address,
    displayName,
    lastMessage,
    lastMessageDate,
    sourceType,
  ];
}

abstract class ContactSelectorState extends Equatable {
  const ContactSelectorState();

  @override
  List<Object?> get props => [];
}

class ContactSelectorInitial extends ContactSelectorState {}

class ContactSelectorLoading extends ContactSelectorState {}

class ContactSelectorLoaded extends ContactSelectorState {
  final List<DeviceContact> contacts;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const ContactSelectorLoaded({
    required this.contacts,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  ContactSelectorLoaded copyWith({
    List<DeviceContact>? contacts,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return ContactSelectorLoaded(
      contacts: contacts ?? this.contacts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [contacts, hasReachedMax, isLoadingMore];
}

class ContactSelectorError extends ContactSelectorState {
  final String message;

  const ContactSelectorError({required this.message});

  @override
  List<Object?> get props => [message];
}
