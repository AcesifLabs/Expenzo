import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqVisionRequest {
  static const defaultModel = 'qwen/qwen3.8-27b';

  final String systemPrompt;
  final String userMessage;
  final String imageBase64;
  final String mimeType;
  final String model;

  static String get configuredModel {
    if (!dotenv.isInitialized) return defaultModel;
    final model = dotenv.env['GROQ_VISION_MODEL']?.trim() ?? '';

    return model.isEmpty ? defaultModel : model;
  }

  const GroqVisionRequest({
    required this.systemPrompt,
    required this.userMessage,
    required this.imageBase64,
    required this.mimeType,
    this.model = defaultModel,
  });
}
