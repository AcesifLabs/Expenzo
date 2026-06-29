import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockDashboardBloc extends Mock implements DashboardBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockDashboardBloc mockDashboardBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockDashboardBloc = MockDashboardBloc();

    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream<AuthState>.value(const AuthInitial()));
    when(() => mockDashboardBloc.state).thenReturn(DashboardInitial());
    when(
      () => mockDashboardBloc.stream,
    ).thenAnswer((_) => Stream<DashboardState>.value(DashboardInitial()));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<DashboardBloc>.value(value: mockDashboardBloc),
        ],
        child: const DashboardPage(),
      ),
    );
  }

  testWidgets('dashboard page renders without error', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.byType(DashboardPage), findsOneWidget);
  });
}
