import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_datasource.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_vision_request.dart';

void main() {
  tearDown(dotenv.clean);

  const request = GroqVisionRequest(
    systemPrompt: 'system',
    userMessage: 'read this',
    imageBase64: 'aGVsbG8=',
    mimeType: 'image/png',
    model: GroqVisionRequest.defaultModel,
  );

  String completion(String content) => jsonEncode({
    'choices': [
      {
        'message': {'role': 'assistant', 'content': content},
      },
    ],
  });

  group('configuredModel', () {
    test('defaults to a model that reads images', () {
      dotenv.loadFromString(envString: 'GROQ_API_KEY=k');

      expect(GroqVisionRequest.configuredModel, GroqVisionRequest.defaultModel);
    });

    test('GROQ_VISION_MODEL overrides the default', () {
      dotenv.loadFromString(
        envString: 'GROQ_API_KEY=k\nGROQ_VISION_MODEL=other/vision-model',
      );

      expect(GroqVisionRequest.configuredModel, 'other/vision-model');
    });

    test('an unloaded env falls back to the default', () {
      expect(GroqVisionRequest.configuredModel, GroqVisionRequest.defaultModel);
    });
  });

  group('completeWithImage', () {
    setUp(() => dotenv.loadFromString(envString: 'GROQ_API_KEY=test-key'));

    test('sends the model, the image as a data URI and JSON mode', () async {
      late Map<String, dynamic> body;
      final client = MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(req.headers['Authorization'], 'Bearer test-key');

        return http.Response(completion('{"amount":13.23}'), 200);
      });

      final content = await GroqDataSource(
        client: client,
      ).completeWithImage(request);

      expect(content, '{"amount":13.23}');
      expect(body['model'], GroqVisionRequest.defaultModel);
      expect(body['response_format'], {'type': 'json_object'});
      final parts = (body['messages'] as List).last['content'] as List;
      expect(parts.last['image_url']['url'], 'data:image/png;base64,aGVsbG8=');
    });

    test('an unknown model is a ServerException with its status', () async {
      final client = MockClient(
        (_) async => http.Response('{"error":"model_not_found"}', 404),
      );

      await expectLater(
        GroqDataSource(client: client).completeWithImage(request),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'status', 404),
        ),
      );
    });
  });
}
