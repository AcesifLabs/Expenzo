import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Groq SSE parsing', () {
    test('parses valid SSE data lines into content tokens', () {
      final lines = [
        'data: {"choices":[{"delta":{"content":"Hello"}}]}',
        'data: {"choices":[{"delta":{"content":" world"}}]}',
        'data: [DONE]',
      ];

      final tokens = <String>[];
      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;

        final data = line.substring(6).trim();
        if (data == '[DONE]') break;

        final json = jsonDecode(data) as Map<String, dynamic>;
        final choices = json['choices'] as List;
        if (choices.isNotEmpty) {
          final delta = choices.first['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            tokens.add(content);
          }
        }
      }

      expect(tokens, ['Hello', ' world']);
    });

    test('handles empty delta gracefully', () {
      final lines = ['data: {"choices":[{"delta":{}}]}', 'data: [DONE]'];

      final tokens = <String>[];
      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;

        final data = line.substring(6).trim();
        if (data == '[DONE]') break;

        final json = jsonDecode(data) as Map<String, dynamic>;
        final choices = json['choices'] as List;
        if (choices.isNotEmpty) {
          final delta = choices.first['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            tokens.add(content);
          }
        }
      }

      expect(tokens, isEmpty);
    });

    test('skips malformed JSON lines', () {
      final lines = [
        'data: not-json',
        'data: {"choices":[{"delta":{"content":"ok"}}]}',
        'data: [DONE]',
      ];

      final tokens = <String>[];
      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;

        final data = line.substring(6).trim();
        if (data == '[DONE]') break;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List;
          if (choices.isNotEmpty) {
            final delta = choices.first['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              tokens.add(content);
            }
          }
        } catch (_) {
          // Skip malformed JSON
        }
      }

      expect(tokens, ['ok']);
    });
  });
}
