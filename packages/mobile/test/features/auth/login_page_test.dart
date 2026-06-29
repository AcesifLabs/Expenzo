import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream<AuthState>.value(const AuthInitial()));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('renders Expenzo title and sign-in button', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Expenzo'), findsOneWidget);
    expect(find.text('Track your expenses effortlessly'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
