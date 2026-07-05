import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('criticalDependenciesReady', () {
    setUp(() async {
      // initCriticalDependencies eagerly awaits SharedPreferences.getInstance();
      // mock it so the test doesn't require platform channels.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      di.criticalInitRunCount = 0;
    });

    test(
      'self-heals by running initCriticalDependencies when not registered',
      () async {
        expect(
          di.getIt.isRegistered<Future<void>>(instanceName: 'criticalReady'),
          isFalse,
          reason: 'precondition: completer not registered yet',
        );
        expect(
          di.criticalInitRunCount,
          equals(0),
          reason: 'precondition: counter should be 0 at start',
        );

        await di.criticalDependenciesReady.timeout(const Duration(seconds: 5));

        expect(
          di.getIt.isRegistered<Future<void>>(instanceName: 'criticalReady'),
          isTrue,
          reason:
              'getter should have registered the completer as a side-effect',
        );
        expect(
          di.criticalInitRunCount,
          equals(1),
          reason: 'first call should have run init and incremented the counter',
        );
      },
    );

    test(
      'returns the manually-registered future when one is already in GetIt',
      () async {
        final completer = Completer<void>();
        completer.complete();
        GetIt.I.registerSingleton<Future<void>>(
          completer.future,
          instanceName: 'criticalReady',
        );

        // The getter must NOT re-call initCriticalDependencies; if it did,
        // GetIt would throw on the duplicate instanceName registration.
        // The counter assertion makes the run-once contract explicit: the
        // warm path must leave the counter at 0.
        await di.criticalDependenciesReady;
        expect(
          di.criticalInitRunCount,
          equals(0),
          reason: 'warm path should NOT re-run init — counter should stay at 0',
        );
      },
    );

    test('re-initializes after GetIt.I.reset() (counter bumps to 2)', () async {
      // First call: counter goes 0 → 1, completer is registered.
      await di.criticalDependenciesReady.timeout(const Duration(seconds: 5));
      expect(
        di.getIt.isRegistered<Future<void>>(instanceName: 'criticalReady'),
        isTrue,
      );
      expect(
        di.criticalInitRunCount,
        equals(1),
        reason: 'first call should have run init',
      );

      // Reset wipes the completer from GetIt (but not the counter).
      await GetIt.I.reset();
      expect(
        di.getIt.isRegistered<Future<void>>(instanceName: 'criticalReady'),
        isFalse,
        reason: 'precondition: reset cleared the registration',
      );
      expect(
        di.criticalInitRunCount,
        equals(1),
        reason: 'precondition: GetIt reset does not reset the counter',
      );

      // Second call: counter goes 1 → 2, completer is re-registered.
      await di.criticalDependenciesReady.timeout(const Duration(seconds: 5));
      expect(
        di.getIt.isRegistered<Future<void>>(instanceName: 'criticalReady'),
        isTrue,
        reason:
            'getter should have re-registered the completer as a side-effect',
      );
      expect(
        di.criticalInitRunCount,
        equals(2),
        reason:
            'second call (after reset) should have re-run init — counter bumps to 2',
      );
    });
  });

  group('featureDependenciesReady', () {
    setUp(() {
      di.featureInitRunCount = 0;
    });

    test('auto-initializes when not yet registered', () async {
      expect(
        di.getIt.isRegistered<Future<void>>(instanceName: 'featureReady'),
        isFalse,
        reason: 'precondition: completer not registered yet',
      );
      expect(
        di.getIt.isRegistered<BudgetRepository>(),
        isFalse,
        reason: 'precondition: feature modules not registered yet',
      );
      expect(
        di.featureInitRunCount,
        equals(0),
        reason: 'precondition: counter should be 0 at start',
      );

      await di.featureDependenciesReady.timeout(const Duration(seconds: 2));

      expect(
        di.getIt.isRegistered<Future<void>>(instanceName: 'featureReady'),
        isTrue,
        reason: 'getter should have registered the completer as a side-effect',
      );
      expect(
        di.getIt.isRegistered<BudgetRepository>(),
        isTrue,
        reason:
            'getter should have run the feature module inits as a side-effect',
      );
      expect(
        di.featureInitRunCount,
        equals(1),
        reason: 'first call should have incremented the counter to 1',
      );
    });

    test('is run-once: subsequent calls do not re-run init', () async {
      // First call runs init and increments the counter to 1.
      await di.featureDependenciesReady.timeout(const Duration(seconds: 2));
      expect(
        di.featureInitRunCount,
        equals(1),
        reason: 'first call should have run init',
      );

      // Second call must NOT re-run init — the counter stays at 1.
      await di.featureDependenciesReady.timeout(const Duration(seconds: 2));
      expect(
        di.featureInitRunCount,
        equals(1),
        reason: 'second call must NOT re-run init — counter should still be 1',
      );
    });
  });
}
