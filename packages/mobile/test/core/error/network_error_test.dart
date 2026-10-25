import 'dart:async';
import 'dart:io';

import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/network_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SocketException and TimeoutException are network errors', () {
    expect(isNetworkError(const SocketException('unreachable')), isTrue);
    expect(isNetworkError(TimeoutException('slow')), isTrue);
  });

  test('HTTP-style exceptions are not treated as offline', () {
    expect(isNetworkError(Exception('Groq API error 500: boom')), isFalse);
  });

  test('failureFromNetworkOrServer picks NetworkFailure offline', () {
    expect(
      failureFromNetworkOrServer(const SocketException('no route')),
      isA<NetworkFailure>(),
    );
    expect(
      failureFromNetworkOrServer(Exception('Groq API error 400')),
      isA<ServerFailure>(),
    );
  });
}
