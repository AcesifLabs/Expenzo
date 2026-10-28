import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FaultInjectionInterceptor extends Interceptor {
  final Duration latency;
  final double errorRate;
  final int status;

  static const _define = String.fromEnvironment('FAULTS');
  static const _serviceUnavailable = 503;

  final Random _random;

  FaultInjectionInterceptor({
    this.latency = Duration.zero,
    this.errorRate = 0,
    this.status = _serviceUnavailable,
    Random? random,
  }) : _random = random ?? Random();

  factory FaultInjectionInterceptor.parse(String spec, {Random? random}) {
    final values = {
      for (final pair in spec.split(','))
        if (pair.split(':') case [final name, final value])
          name.trim(): value.trim(),
    };

    return FaultInjectionInterceptor(
      latency: Duration(
        milliseconds: int.tryParse(values['latency'] ?? '') ?? 0,
      ),
      errorRate: (double.tryParse(values['error_rate'] ?? '') ?? 0).clamp(0, 1),
      status: int.tryParse(values['status'] ?? '') ?? _serviceUnavailable,
      random: random,
    );
  }

  static FaultInjectionInterceptor? fromEnvironment() =>
      kReleaseMode || _define.isEmpty
      ? null
      : FaultInjectionInterceptor.parse(_define);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (_random.nextDouble() >= errorRate) return handler.next(options);

    handler.reject(
      status == 0
          ? DioException.connectionError(
              requestOptions: options,
              reason: 'Injected fault',
            )
          : DioException.badResponse(
              statusCode: status,
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: status),
            ),
    );
  }
}
