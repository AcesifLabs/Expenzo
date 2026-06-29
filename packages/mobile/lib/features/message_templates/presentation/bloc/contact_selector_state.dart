import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/source_types.dart';

sealed class ContactSelectorState extends Equatable {
  @override
  List<Object?> get props => [];

  const ContactSelectorState();
}

class ContactSelectorInitial extends ContactSelectorState {
  const ContactSelectorInitial();
}

class ContactSelectorLoading extends ContactSelectorState {
  const ContactSelectorLoading();
}

class ContactSelectorLoaded extends ContactSelectorState {
  final List<DeviceContact> contacts;
  final bool hasReachedMax;
  final bool isLoadingMore;

  @override
  List<Object?> get props => [contacts, hasReachedMax, isLoadingMore];

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
}

class ContactSelectorError extends ContactSelectorState {
  final String message;

  @override
  List<Object?> get props => [message];

  const ContactSelectorError({required this.message});
}

class DeviceContact extends Equatable {
  final String address;
  final String displayName;
  final String lastMessage;
  final DateTime lastMessageDate;
  final ExpenseSource sourceType;

  @override
  List<Object?> get props => [
    address,
    displayName,
    lastMessage,
    lastMessageDate,
    sourceType,
  ];

  const DeviceContact({
    required this.address,
    required this.displayName,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.sourceType,
  });
}
