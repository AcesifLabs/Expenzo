import 'dart:async';
import 'dart:io';

import 'failures.dart';

bool isNetworkError(Object error) {
  if (error is SocketException || error is TimeoutException) return true;
  final text = error.toString().toLowerCase();

  return text.contains('socketexception') ||
      text.contains('clientexception') ||
      text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('connection refused') ||
      text.contains('connection reset') ||
      text.contains('connection timed out') ||
      text.contains('network_error') ||
      text.contains('network-request-failed');
}

Failure failureFromNetworkOrServer(Object error) {
  final message = error.toString();
  if (isNetworkError(error)) return NetworkFailure(message: message);

  return ServerFailure(message: message);
}
