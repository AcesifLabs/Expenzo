import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_chat_completion.dart';

void main() {
  group('GroqChatCompletion.fromJson', () {
    test('parses message content from a completion payload', () {
      final completion = GroqChatCompletion.fromJson(
        jsonDecode('{"choices":[{"message":{"content":"hello world"}}]}'),
      );

      expect(completion.choices, hasLength(1));
      expect(completion.firstMessageContent, 'hello world');
      expect(completion.firstDeltaContent, isNull);
    });

    test('parses delta content from an SSE payload', () {
      final completion = GroqChatCompletion.fromJson(
        jsonDecode('{"choices":[{"delta":{"content":"tok"}}]}'),
      );

      expect(completion.firstDeltaContent, 'tok');
      expect(completion.firstMessageContent, isNull);
    });

    test('returns empty choices when choices is missing', () {
      final completion = GroqChatCompletion.fromJson(jsonDecode('{}'));

      expect(completion.choices, isEmpty);
      expect(completion.firstMessageContent, isNull);
    });

    test('throws when root is not an object', () {
      expect(
        () => GroqChatCompletion.fromJson(jsonDecode('[]')),
        throwsFormatException,
      );
    });
  });
}
