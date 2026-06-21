import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('criticalDependenciesReady', () {
    test('throws when not yet registered', () async {
      expect(
        () => di.criticalDependenciesReady,
        throwsA(isA<Object>()),
      );
    });

    test('returns a Future<void> when registered in get_it', () async {
      // Simulate what initCriticalDependencies does: register a completed future.
      final completer = Completer<void>();
      completer.complete();
      GetIt.I.registerSingleton<Future<void>>(
        completer.future,
        instanceName: 'criticalReady',
      );

      await di.criticalDependenciesReady; // should complete immediately
    });

    test('throws again after GetIt.I.reset()', () async {
      // Register
      final completer = Completer<void>();
      completer.complete();
      GetIt.I.registerSingleton<Future<void>>(
        completer.future,
        instanceName: 'criticalReady',
      );

      await di.criticalDependenciesReady;

      // Wipe
      await GetIt.I.reset();

      // Should throw — no longer registered
      expect(
        () => di.criticalDependenciesReady,
        throwsA(isA<Object>()),
      );

      // Re-register and it works again
      final completer2 = Completer<void>();
      completer2.complete();
      GetIt.I.registerSingleton<Future<void>>(
        completer2.future,
        instanceName: 'criticalReady',
      );

      await di.criticalDependenciesReady;
    });
  });

  group('featureDependenciesReady', () {
    test('throws when not yet registered', () async {
      expect(
        () => di.featureDependenciesReady,
        throwsA(isA<Object>()),
      );
    });
  });
}
