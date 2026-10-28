import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'groq_chat_completion.dart';
import 'groq_vision_request.dart';

class GroqDataSource {
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'openai/gpt-oss-20b';

  final http.Client _client;

  GroqDataSource({http.Client? client}) : _client = client ?? http.Client();

  Stream<String> streamChat({
    required String systemPrompt,
    required String userMessage,
  }) async* {
    final String apiKey;
    try {
      apiKey = _requireApiKey();
    } catch (e) {
      yield* Stream.error(e);

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
      'max_completion_tokens': 2048,
      'top_p': 1,
      'reasoning_effort': 'low',
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

  Future<String> completeWithImage(GroqVisionRequest request) async {
    final apiKey = _requireApiKey();
    appLogger.info(
      'Groq vision request model=${request.model} '
      'mimeType=${request.mimeType} '
      'imageBytes≈${(request.imageBase64.length * 3 / 4).round()}',
    );

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': request.userMessage},
              {
                'type': 'image_url',
                'image_url': {
                  'url':
                      'data:${request.mimeType};base64,${request.imageBase64}',
                },
              },
            ],
          },
        ],
        'model': request.model,
        'temperature': 0.1,
        'max_completion_tokens': 1024,
        'response_format': {'type': 'json_object'},
        'reasoning_effort': 'none',
      }),
    );

    if (response.statusCode != 200) {
      appLogger.error(
        'Groq vision API error status=${response.statusCode} '
        'model=${request.model} body=${response.body}',
      );
      throw ServerException(
        message: 'Groq API error: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final completion = GroqChatCompletion.fromJson(jsonDecode(response.body));
    final content = completion.firstMessageContent;
    if (content == null || content.isEmpty) {
      appLogger.error(
        'Groq vision API returned empty content: ${response.body}',
      );
      throw Exception('Groq API returned empty content');
    }

    appLogger.info('Groq vision response: $content');

    return content;
  }

  StreamTransformer<String, String> _parseSseLines() {
    return StreamTransformer.fromHandlers(handleData: _handleSseLine);
  }

  String _requireApiKey() {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      appLogger.error('GROQ_API_KEY is missing from environment');
      throw Exception(
        'GROQ_API_KEY is not configured. AI features are unavailable.',
      );
    }

    return apiKey;
  }

  void _handleSseLine(String line, EventSink<String> sink) {
    if (!line.startsWith('data: ')) return;

    final data = line.substring(6).trim();
    if (data == '[DONE]') return;

    try {
      final content = GroqChatCompletion.fromJson(
        jsonDecode(data),
      ).firstDeltaContent;
      if (content != null && content.isNotEmpty) {
        sink.add(content);
      }
    } catch (e) {
      appLogger.warning('Skipped an unreadable AI stream line', e);
    }
  }
}
