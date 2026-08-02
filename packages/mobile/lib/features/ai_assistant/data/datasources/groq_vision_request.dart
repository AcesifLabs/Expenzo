class GroqVisionRequest {
  static const defaultModel = 'qwen/qwen3.6-27b';

  final String systemPrompt;
  final String userMessage;
  final String imageBase64;
  final String mimeType;
  final String model;

  const GroqVisionRequest({
    required this.systemPrompt,
    required this.userMessage,
    required this.imageBase64,
    required this.mimeType,
    this.model = defaultModel,
  });
}
