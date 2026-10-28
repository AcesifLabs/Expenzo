import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../integration_test/support/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> seedRecords(int count) async {
    final db = di.getIt<AppDatabase>();
    final now = DateTime.now();
    await db.batch(
      (b) => b.insertAll(db.records, [
        for (var i = 0; i < count; i++)
          RecordsCompanion.insert(
            id: 'perf-$i',
            amount: -(i % 500 + 10).toDouble(),
            description: 'Perf record $i',
            date: now.subtract(Duration(hours: i)),
            recordType: 'OUT',
          ),
      ]),
    );
  }

  void go(WidgetTester tester, String location) =>
      GoRouter.of(tester.element(find.byType(Navigator).first)).go(location);

  testWidgets('performance', (tester) async {
    await markOnboarded();
    await startApp(tester);
    await seedRecords(5000);

    go(tester, AppRootTab.activity.location);
    await settle(tester, 3);
    await binding.traceAction(() async {
      final list = find.byType(Scrollable).first;
      for (var i = 0; i < 5; i++) {
        await tester.fling(list, const Offset(0, -2000), 4000);
        await settle(tester, 1);
      }
    }, reportKey: 'records_scroll');

    go(tester, AppRootTab.home.location);
    await settle(tester, 3);

    final dashboard = tester
        .element(find.byType(DashboardView))
        .read<DashboardBloc>();
    await binding.traceAction(() async {
      dashboard.add(const ChangeDateRange(preset: DateRangePreset.lastMonth));
      await settle(tester, 2);
      dashboard.add(const ChangeDateRange(preset: DateRangePreset.thisYear));
      await settle(tester, 2);
    }, reportKey: 'dashboard_range');

    await binding.traceAction(() async {
      go(tester, AppRootTab.reports.location);
      await settle(tester, 3);
    }, reportKey: 'open_reports');
  });
}
