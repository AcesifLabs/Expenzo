import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  @override
  List<Object?> get props => [role, content, timestamp];

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  ChatMessage.user(String text)
    : role = ChatRole.user,
      content = text,
      timestamp = DateTime.now();

  ChatMessage.assistant(String text)
    : role = ChatRole.assistant,
      content = text,
      timestamp = DateTime.now();
}
