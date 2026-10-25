import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/lifecycle/local_data_epoch.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/data_wipe/presentation/helpers/refresh_after_local_wipe.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

import '../../../../support/core_screens.dart';

void main() {
  tearDown(() => di.getIt.reset());

  testWidgets('rebuilds tabs, reloads settings and root blocs, opens Home', (
    tester,
  ) async {
    final epoch = LocalDataEpoch();
    addTearDown(epoch.dispose);
    final settings = mockBloc<MockSettingsBloc, SettingsState>(
      MockSettingsBloc(),
      const SettingsInitial(),
    );
    final categories = mockBloc<MockCategoryBloc, CategoryState>(
      MockCategoryBloc(),
      const CategoryInitial(),
    );
    final records = mockBloc<MockRecordBloc, RecordState>(
      MockRecordBloc(),
      const RecordInitial(),
    );
    di.getIt
      ..registerSingleton<LocalDataEpoch>(epoch)
      ..registerSingleton<SettingsBloc>(settings);
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/settings',
          builder: (context, _) => TextButton(
            onPressed: () => refreshAfterLocalWipe(context),
            child: const Text('wipe'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CategoryBloc>.value(value: categories),
          BlocProvider<RecordBloc>.value(value: records),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('wipe'));
    await tester.pumpAndSettle();

    expect(epoch.value, 1);
    verify(() => settings.add(const LoadSettings())).called(1);
    verify(() => categories.add(const LoadCategories())).called(1);
    verify(() => records.add(const LoadRecords())).called(1);
    expect(find.text('home'), findsOneWidget);
  });
}
