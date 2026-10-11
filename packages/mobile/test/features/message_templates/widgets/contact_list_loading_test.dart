import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/contact_selector_page.dart';
import '../../../support/pump_localized.dart';

class _MockContactSelectorBloc extends Mock implements ContactSelectorBloc {}

class _MockMessageSourcesBloc extends Mock implements MessageSourcesBloc {}

class _FakeContactSelectorEvent extends Fake implements ContactSelectorEvent {}

class _FakeMessageSourcesEvent extends Fake implements MessageSourcesEvent {}

final _contact = DeviceContact(
  address: '16216',
  displayName: '16216',
  lastMessage: 'Your A/C XX1234 debited by BDT 450.00',
  lastMessageDate: DateTime(2026, 10, 11),
  sourceType: ExpenseSource.sms,
);

void main() {
  late _MockContactSelectorBloc contactsBloc;
  late _MockMessageSourcesBloc sourcesBloc;

  setUpAll(() {
    registerFallbackValue(_FakeContactSelectorEvent());
    registerFallbackValue(_FakeMessageSourcesEvent());
  });

  setUp(() {
    contactsBloc = _MockContactSelectorBloc();
    sourcesBloc = _MockMessageSourcesBloc();
    when(
      () => contactsBloc.stream,
    ).thenAnswer((_) => const Stream<ContactSelectorState>.empty());
    when(() => contactsBloc.close()).thenAnswer((_) async {});
    when(() => contactsBloc.add(any())).thenReturn(null);
    when(
      () => sourcesBloc.state,
    ).thenReturn(const MessageSourcesLoaded(sources: []));
    when(
      () => sourcesBloc.stream,
    ).thenAnswer((_) => const Stream<MessageSourcesState>.empty());
    when(() => sourcesBloc.close()).thenAnswer((_) async {});
    when(() => sourcesBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpWith(WidgetTester tester, ContactSelectorState state) async {
    when(() => contactsBloc.state).thenReturn(state);
    await tester.pumpWidget(
      translated(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ContactSelectorBloc>.value(value: contactsBloc),
                BlocProvider<MessageSourcesBloc>.value(value: sourcesBloc),
              ],
              child: const ContactSelectorView(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a fully loaded short list shows no spinner', (tester) async {
    await pumpWith(
      tester,
      ContactSelectorLoaded(contacts: [_contact], hasReachedMax: true),
    );

    expect(find.text('16216'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a list waiting on the next page shows no spinner', (
    tester,
  ) async {
    // More pages exist, but nothing is being fetched right now.
    await pumpWith(tester, ContactSelectorLoaded(contacts: [_contact]));

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows the spinner row only while loading more', (tester) async {
    await pumpWith(
      tester,
      ContactSelectorLoaded(contacts: [_contact], isLoadingMore: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
