import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqDataSource {
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.1-8b-instant';

  final http.Client _client;

  GroqDataSource({http.Client? client}) : _client = client ?? http.Client();

  Stream<String> streamChat({
    required String systemPrompt,
    required String userMessage,
  }) async* {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      yield* Stream.error(
        Exception(
          'GROQ_API_KEY is not configured. AI assistant is unavailable.',
        ),
      );

      return;
    }

    final request = http.Request('POST', Uri.parse(_endpoint));
    request.headers['Content-Type'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.body = jsonEncode({
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userMessage},
      ],
      'model': _model,
      'temperature': 1,
      'max_completion_tokens': 1024,
      'top_p': 1,
      'stream': true,
    });

    final response = await _client.send(request);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      yield* Stream.error(
        Exception('Groq API error ${response.statusCode}: $body'),
      );

      return;
    }

    yield* response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .transform(_parseSseLines());
  }

  StreamTransformer<String, String> _parseSseLines() {
    return StreamTransformer.fromHandlers(handleData: _handleSseLine);
  }

  void _handleSseLine(String line, EventSink<String> sink) {
    if (!line.startsWith('data: ')) return;

    final data = line.substring(6).trim();
    if (data == '[DONE]') return;

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final choices = json['choices'] as List?;
      if (choices == null || choices.isEmpty) return;

      final delta = choices.first['delta'] as Map<String, dynamic>?;
      final content = delta?['content'] as String?;
      if (content != null && content.isNotEmpty) {
        sink.add(content);
      }
    } catch (_) {
      // Skip malformed JSON lines
    }
  }
}
