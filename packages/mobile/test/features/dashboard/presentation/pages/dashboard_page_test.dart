import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/receipt_scan_banner.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/pages/receipt_scan_camera_page.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import '../../../../support/pump_localized.dart';
import '../../../../support/receipt_camera.dart';

class _MockDashboardBloc extends Mock implements DashboardBloc {}

class _MockAuthBloc extends Mock implements AuthBloc {}

class _MockRecordBloc extends Mock implements RecordBloc {}

class _MockCategoryBloc extends Mock implements CategoryBloc {}

class _MockRecurringRepository extends Mock implements RecurringRepository {}

class _MockGetBudgets extends Mock implements GetBudgets {}

class _MockGetCategories extends Mock implements GetCategories {}

class _FakeDashboardEvent extends Fake implements DashboardEvent {}

class _FakeRecordEvent extends Fake implements RecordEvent {}

class _FakeCategoryEvent extends Fake implements CategoryEvent {}

void main() {
  late _MockDashboardBloc dashboardBloc;
  late _MockAuthBloc authBloc;
  late _MockRecordBloc recordBloc;
  late _MockCategoryBloc categoryBloc;

  setUpAll(() {
    registerFallbackValue(_FakeDashboardEvent());
    registerFallbackValue(_FakeRecordEvent());
    registerFallbackValue(_FakeCategoryEvent());
    registerFallbackValue(const GetCategoriesParams());
  });

  setUp(() {
    dashboardBloc = _MockDashboardBloc();
    authBloc = _MockAuthBloc();
    recordBloc = _MockRecordBloc();
    categoryBloc = _MockCategoryBloc();

    when(() => dashboardBloc.state).thenReturn(const DashboardLoading());
    when(
      () => dashboardBloc.stream,
    ).thenAnswer((_) => const Stream<DashboardState>.empty());
    when(() => dashboardBloc.close()).thenAnswer((_) async {});
    when(() => dashboardBloc.add(any())).thenReturn(null);
    when(() => authBloc.state).thenReturn(const Unauthenticated());
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => authBloc.close()).thenAnswer((_) async {});
    when(() => recordBloc.state).thenReturn(const RecordInitial());
    when(
      () => recordBloc.stream,
    ).thenAnswer((_) => const Stream<RecordState>.empty());
    when(() => recordBloc.close()).thenAnswer((_) async {});
    when(() => recordBloc.add(any())).thenReturn(null);
    when(() => categoryBloc.state).thenReturn(const CategoryLoaded([]));
    when(
      () => categoryBloc.stream,
    ).thenAnswer((_) => const Stream<CategoryState>.empty());
    when(() => categoryBloc.close()).thenAnswer((_) async {});
    when(() => categoryBloc.add(any())).thenReturn(null);

    final getBudgets = _MockGetBudgets();
    when(() => getBudgets()).thenAnswer((_) async => const Right([]));
    final getCategories = _MockGetCategories();
    when(() => getCategories(any())).thenAnswer((_) async => const Right([]));

    di.getIt
      // Marks feature DI as done so the real modules never load.
      ..registerSingleton<Future<void>>(
        Future<void>.value(),
        instanceName: 'featureReady',
      )
      ..registerSingleton<RecurringRepository>(_MockRecurringRepository())
      ..registerSingleton<GetBudgets>(getBudgets)
      ..registerSingleton<GetCategories>(getCategories);

    mockCameraPermissionDenied();
  });

  tearDown(() async {
    clearCameraPermissionMock();
    await di.getIt.unregister<Future<void>>(instanceName: 'featureReady');
    await di.getIt.unregister<RecurringRepository>();
    await di.getIt.unregister<GetBudgets>();
    await di.getIt.unregister<GetCategories>();
  });

  Future<void> pumpDashboard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      Scaffold(
        body: BlocProvider<DashboardBloc>.value(
          value: dashboardBloc,
          child: const DashboardView(),
        ),
      ),
      wrap: (app) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<RecordBloc>.value(value: recordBloc),
          BlocProvider<CategoryBloc>.value(value: categoryBloc),
        ],
        child: app,
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the scan banner while the dashboard is loading', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.text('Scan a receipt'), findsOneWidget);
  });

  testWidgets('the banner opens the sheet in scan mode, then the camera', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Scan a receipt'));
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (w) => w is NewTransactionSheet && w.startWithReceiptScan,
      ),
      findsOneWidget,
    );

    await pumpPastTransitions(tester);

    expect(find.byType(ReceiptScanCameraPage), findsOneWidget);
  });

  testWidgets('the banner is disabled while its sheet is open', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Scan a receipt'));
    await tester.pump();

    final banner = tester.widget<ReceiptScanBanner>(
      find.byType(ReceiptScanBanner),
    );
    expect(banner.onTap, isNull);
  });
}
