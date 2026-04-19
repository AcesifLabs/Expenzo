import 'package:equatable/equatable.dart';

enum AutoCreateOption { autoCreate, promptUser, manualOnly }

class MessageSource extends Equatable {
  final String id;
  final String contactId; // Address/Sender string
  final String contactName; // Display name if available, else address
  final bool isMonitored;
  final AutoCreateOption autoCreateOption;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MessageSource({
    required this.id,
    required this.contactId,
    required this.contactName,
    this.isMonitored = false,
    this.autoCreateOption = AutoCreateOption.promptUser,
    required this.createdAt,
    required this.updatedAt,
  });

  MessageSource copyWith({
    String? id,
    String? contactId,
    String? contactName,
    bool? isMonitored,
    AutoCreateOption? autoCreateOption,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageSource(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      isMonitored: isMonitored ?? this.isMonitored,
      autoCreateOption: autoCreateOption ?? this.autoCreateOption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    contactId,
    contactName,
    isMonitored,
    autoCreateOption,
    createdAt,
    updatedAt,
  ];
}
