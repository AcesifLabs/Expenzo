import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/template_editor_page.dart';
import 'package:expense_tracker/features/message_templates/presentation/widgets/template_editor_components.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';

class MockTemplateEditorBloc extends Mock implements TemplateEditorBloc {}

class MockMessageSourcesBloc extends Mock implements MessageSourcesBloc {}

class _FakeExpenseTemplate extends Fake implements ExpenseTemplate {}

class _FakeMessageSource extends Fake implements MessageSource {}

class _FakeTemplateEditorEvent extends Fake implements TemplateEditorEvent {}

void main() {
  late MockTemplateEditorBloc mockEditorBloc;
  late MockMessageSourcesBloc mockSourcesBloc;

  final testSource = MessageSource(
    id: 'src-1',
    contactId: 'contact-1',
    contactName: 'bKash',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testSms = SmsMessage(
    id: 'sms-1',
    address: 'bKash',
    body:
        'Rs.500.00 debited from A/C XX1234 at bKash Merchant. Fee: Rs.0. Balance: Rs.12,340.00',
    date: DateTime(2026, 7, 5),
    read: true,
    type: SmsType.received,
  );

  setUpAll(() {
    registerFallbackValue(_FakeExpenseTemplate());
    registerFallbackValue(_FakeMessageSource());
    registerFallbackValue(_FakeTemplateEditorEvent());
  });

  setUp(() {
    mockEditorBloc = MockTemplateEditorBloc();
    mockSourcesBloc = MockMessageSourcesBloc();

    when(() => mockEditorBloc.state).thenReturn(const TemplateEditorInitial());
    when(
      () => mockEditorBloc.stream,
    ).thenAnswer((_) => Stream<TemplateEditorState>.empty());
    when(() => mockEditorBloc.close()).thenAnswer((_) async {});
    when(() => mockEditorBloc.add(any())).thenReturn(null);

    when(
      () => mockSourcesBloc.state,
    ).thenReturn(const MessageSourcesLoaded(sources: []));
    when(
      () => mockSourcesBloc.stream,
    ).thenAnswer((_) => Stream<MessageSourcesState>.empty());
    when(() => mockSourcesBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TemplateEditorBloc>.value(value: mockEditorBloc),
          BlocProvider<MessageSourcesBloc>.value(value: mockSourcesBloc),
        ],
        child: InteractiveTemplateBuilder(
          source: testSource,
          sampleMessage: testSms,
        ),
      ),
    );
  }

  group('Template Editor Flow', () {
    testWidgets('renders Step 1 initially with trigger words', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Step 1: Pick a Trigger Word'), findsOneWidget);
      expect(find.byType(StepProgressIndicator), findsOneWidget);
      expect(find.byType(MessagePreviewCard), findsOneWidget);

      // Verify message preview shows sender name and body
      // bKash appears in MessagePreviewCard sender AND as a TriggerWordChip
      expect(find.text('bKash'), findsWidgets);
      expect(find.textContaining('Rs.500.00 debited'), findsOneWidget);

      // Verify trigger word chips are rendered from the SMS body
      expect(find.byType(TriggerWordChip), findsWidgets);
      // "debited" should be one of the chip words
      expect(find.text('debited'), findsOneWidget);

      // Next button should be disabled (no trigger selected)
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('selecting a trigger word enables Next button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the "debited" trigger word chip
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      // Next button should now be enabled
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('full flow: pick trigger → pick amount → review → save', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // --- Step 1: Pick a Trigger Word ---
      expect(find.text('Step 1: Pick a Trigger Word'), findsOneWidget);

      // Tap the "debited" trigger word chip
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      // Tap Next to go to Step 2
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      await tester.pumpAndSettle();

      // --- Step 2: Select the Amount ---
      expect(find.text('Step 2: Select the Amount'), findsOneWidget);
      expect(find.byType(MessagePreviewCard), findsOneWidget);

      // Section label should be present
      expect(find.text('Amounts found in this message:'), findsOneWidget);

      // Amount rows should be rendered (AmountRow widgets)
      expect(find.byType(AmountRow), findsWidgets);

      // Tap the first amount (500.00)
      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();

      // Next: Review button should be enabled
      final reviewButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next: Review'),
      );
      expect(reviewButton.onPressed, isNotNull);

      // Tap Next: Review
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next: Review'));
      await tester.pumpAndSettle();

      // --- Step 3: Review ---
      expect(find.text('Step 3: Review'), findsOneWidget);

      // Review card should show the selected values
      expect(find.text('Sender'), findsOneWidget);
      expect(find.text('Trigger Word'), findsOneWidget);
      expect(find.text('Sample Amount'), findsOneWidget);
      expect(find.text('debited'), findsOneWidget); // in review card
      expect(find.text('500.00'), findsOneWidget); // in review card

      // Tap Save & Finish
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save & Finish'));
      // Use pump() instead of pumpAndSettle() to avoid waiting for
      // the RetroactiveScanDialog's 2-second timer
      await tester.pump();

      // Verify the bloc received a SaveTemplateEvent
      final captured = verify(
        () => mockEditorBloc.add(captureAny<TemplateEditorEvent>()),
      ).captured;
      expect(captured.last, isA<SaveTemplateEvent>());

      final event = captured.last as SaveTemplateEvent;
      expect(event.template.triggerWord, 'debited');
      expect(event.template.sourceId, 'src-1');
      expect(event.source.isMonitored, isTrue);
    });

    testWidgets('back navigation works from Step 2 to Step 1', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Select trigger and go to Step 2
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step 2: Select the Amount'), findsOneWidget);

      // Tap Back
      await tester.tap(find.widgetWithText(TextButton, 'Back'));
      await tester.pumpAndSettle();

      // Should be back on Step 1
      expect(find.text('Step 1: Pick a Trigger Word'), findsOneWidget);
    });

    testWidgets('back navigation works from Step 3 to Step 2', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Step 1 → Step 2
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      await tester.pumpAndSettle();

      // Step 2 → Step 3
      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next: Review'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3: Review'), findsOneWidget);

      // Tap Back
      await tester.tap(find.widgetWithText(TextButton, 'Back'));
      await tester.pumpAndSettle();

      // Should be back on Step 2
      expect(find.text('Step 2: Select the Amount'), findsOneWidget);
    });

    testWidgets('deselecting a trigger word disables Next button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Select trigger
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      var nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      expect(nextButton.onPressed, isNotNull);

      // Deselect trigger by tapping again
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Step 3 shows error snackbar on save failure', (tester) async {
      // Use a stream controller so we can emit states after save is triggered
      final stateController = StreamController<TemplateEditorState>.broadcast();

      when(
        () => mockEditorBloc.state,
      ).thenReturn(const TemplateEditorInitial());
      when(
        () => mockEditorBloc.stream,
      ).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Complete full flow through Step 3
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next: Review'));
      await tester.pumpAndSettle();

      // Tap Save & Finish
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save & Finish'));
      await tester.pump();

      // Verify save event was dispatched
      verify(() => mockEditorBloc.add(any<TemplateEditorEvent>())).called(1);

      // Simulate bloc emitting saving then error
      stateController.add(const TemplateEditorSaving());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      stateController.add(const TemplateEditorError('Database error'));
      await tester.pumpAndSettle();

      // Error snackbar should appear
      expect(
        find.text('Error saving template: Database error'),
        findsOneWidget,
      );

      await stateController.close();
    });

    testWidgets('step progress indicator updates across steps', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Step 1 - indicator should be present
      expect(find.byType(StepProgressIndicator), findsOneWidget);

      // Go to Step 2
      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Next: Select Amount'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StepProgressIndicator), findsOneWidget);

      // Go to Step 3
      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next: Review'));
      await tester.pumpAndSettle();
      expect(find.byType(StepProgressIndicator), findsOneWidget);
    });
  });
}
