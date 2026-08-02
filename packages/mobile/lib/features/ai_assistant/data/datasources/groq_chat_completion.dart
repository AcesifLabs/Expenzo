/// Typed Groq chat.completions JSON (non-streaming and SSE delta payloads).
class GroqChatCompletion {
  final List<GroqChoice> choices;

  String? get firstMessageContent {
    if (choices.isEmpty) return null;

    return choices.first.message?.content;
  }

  String? get firstDeltaContent {
    if (choices.isEmpty) return null;

    return choices.first.delta?.content;
  }

  const GroqChatCompletion({required this.choices});

  factory GroqChatCompletion.fromJson(Object? json) {
    final map = _asObjectMap(json);
    if (map == null) {
      throw FormatException('Groq response is not a JSON object: $json');
    }

    final rawChoices = map['choices'];
    if (rawChoices is! List) {
      return const GroqChatCompletion(choices: []);
    }

    final choices = <GroqChoice>[];
    for (final item in rawChoices) {
      final choice = GroqChoice.fromJson(item);
      if (choice != null) choices.add(choice);
    }

    return GroqChatCompletion(choices: choices);
  }
}

class GroqChoice {
  final GroqMessage? message;
  final GroqDelta? delta;

  const GroqChoice({this.message, this.delta});

  static GroqChoice? fromJson(Object? json) {
    final map = _asObjectMap(json);
    if (map == null) return null;

    return GroqChoice(
      message: GroqMessage.fromJson(map['message']),
      delta: GroqDelta.fromJson(map['delta']),
    );
  }
}

class GroqMessage {
  final String? content;

  const GroqMessage({this.content});

  static GroqMessage? fromJson(Object? json) {
    final map = _asObjectMap(json);
    if (map == null) return null;
    final content = map['content'];

    return GroqMessage(content: content is String ? content : null);
  }
}

class GroqDelta {
  final String? content;

  const GroqDelta({this.content});

  static GroqDelta? fromJson(Object? json) {
    final map = _asObjectMap(json);
    if (map == null) return null;
    final content = map['content'];

    return GroqDelta(content: content is String ? content : null);
  }
}

Map<String, Object?>? _asObjectMap(Object? value) {
  if (value is! Map) return null;

  return Map<String, Object?>.from(value);
}
