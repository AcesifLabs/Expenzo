import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads `.env.prod` or `.env.dev`. A failure is logged, never thrown.
Future<void> loadEnv() async {
  const isProd = bool.fromEnvironment('dart.vm.product');
  try {
    await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');
  } catch (e, s) {
    debugPrint('Error: $e\n$s');
    debugPrint('Failed to load .env: $e');
  }
}
