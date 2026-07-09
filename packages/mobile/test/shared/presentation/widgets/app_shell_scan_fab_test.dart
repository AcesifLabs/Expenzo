import 'dart:async';

import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_state.dart';
import 'package:expense_tracker/features/sms_parser/application/realtime_sms_processor.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRealtimeSmsProcessor extends Mock implements RealtimeSmsProcessor {}

class _MockDashboardBloc extends Mock implements DashboardBloc {}

class _MockAuthBloc extends Mock implements AuthBloc {}

class _MockContactSelectorBloc extends Mock implements ContactSelectorBloc {}

class _MockMessageSourcesBloc extends Mock implements MessageSourcesBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');

  late _MockRealtimeSmsProcessor processor;
  late _MockDashboardBloc dashboardBloc;
  late _MockAuthBloc authBloc;
  late _MockContactSelectorBloc contactSelectorBloc;
  late _MockMessageSourcesBloc messageSourcesBloc;

  Finder scanFabFinder() => find.byWidgetPredicate(
    (widget) => widget is FloatingActionButton && widget.heroTag == 'scan_fab',
  );

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 20,
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  Future<void> setKeyboardInset(WidgetTester tester, double bottom) async {
    tester.view.viewInsets = FakeViewPadding(bottom: bottom);
    tester.binding.handleMetricsChanged();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  setUp(() {
    di.getIt.reset();
    processor = _MockRealtimeSmsProcessor();
    dashboardBloc = _MockDashboardBloc();
    authBloc = _MockAuthBloc();
    contactSelectorBloc = _MockContactSelectorBloc();
    messageSourcesBloc = _MockMessageSourcesBloc();

    when(() => processor.start()).thenAnswer((_) async {});
    when(() => dashboardBloc.close()).thenAnswer((_) async {});
    when(() => authBloc.close()).thenAnswer((_) async {});
    when(() => contactSelectorBloc.close()).thenAnswer((_) async {});
    when(() => messageSourcesBloc.close()).thenAnswer((_) async {});

    when(() => dashboardBloc.state).thenReturn(const DashboardInitial());
    when(
      () => dashboardBloc.stream,
    ).thenAnswer((_) => const Stream<DashboardState>.empty());

    when(() => authBloc.state).thenReturn(const Unauthenticated());
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());

    when(() => contactSelectorBloc.state).thenReturn(
      ContactSelectorLoaded(
        contacts: List.generate(
          100,
          (index) => DeviceContact(
            address: 'bkash_$index',
            displayName: index == 0 ? 'bKash' : 'Contact $index',
            lastMessage: 'debited',
            lastMessageDate: DateTime(2026, 7, 10),
            sourceType: ExpenseSource.sms,
          ),
        ),
      ),
    );
    when(
      () => contactSelectorBloc.stream,
    ).thenAnswer((_) => const Stream<ContactSelectorState>.empty());

    when(
      () => messageSourcesBloc.state,
    ).thenReturn(const MessageSourcesLoaded(sources: []));
    when(
      () => messageSourcesBloc.stream,
    ).thenAnswer((_) => const Stream<MessageSourcesState>.empty());

    di.getIt.registerSingleton<RealtimeSmsProcessor>(processor);
    di.getIt.registerFactory<DashboardBloc>(() => dashboardBloc);
    di.getIt.registerFactory<AuthBloc>(() => authBloc);
    di.getIt.registerFactory<ContactSelectorBloc>(() => contactSelectorBloc);
    di.getIt.registerFactory<MessageSourcesBloc>(() => messageSourcesBloc);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'checkPermissionStatus') return 1;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    addTearDown(() {});
    di.getIt.reset();
  });

  testWidgets('hides scan fab when the keyboard is visible', (tester) async {
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Scan'));
    await pumpUntilFound(tester, scanFabFinder());

    expect(scanFabFinder(), findsOneWidget);

    await setKeyboardInset(tester, 300);

    expect(scanFabFinder(), findsNothing);

    await setKeyboardInset(tester, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('shows scan fab again when the keyboard collapses', (
    tester,
  ) async {
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Scan'));
    await pumpUntilFound(tester, scanFabFinder());

    await setKeyboardInset(tester, 300);
    expect(scanFabFinder(), findsNothing);

    await setKeyboardInset(tester, 0);
    expect(scanFabFinder(), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });
}
