import 'dart:async';
import 'package:expense_tracker/i18n/strings.g.dart';

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
import '../../support/pump_localized.dart';

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
    return translated(
      MaterialApp(
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
      ),
    );
  }

  group('Template Editor Flow', () {
    testWidgets('renders Step 1 initially with trigger words', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3: Choose a key word'), findsOneWidget);
      expect(find.byType(StepProgressIndicator), findsOneWidget);
      expect(find.byType(MessagePreviewCard), findsOneWidget);

      expect(find.text('bKash'), findsWidgets);
      expect(find.textContaining('Rs.500.00 debited'), findsOneWidget);

      expect(find.byType(TriggerWordChip), findsWidgets);

      expect(find.text('debited'), findsOneWidget);

      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('selecting a trigger word enables Next button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('full flow: pick trigger → pick amount → review → save', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3: Choose a key word'), findsOneWidget);

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3: Choose the amount'), findsOneWidget);
      expect(find.byType(MessagePreviewCard), findsOneWidget);

      expect(find.text('Amounts found in this message:'), findsOneWidget);

      expect(find.byType(AmountRow), findsWidgets);

      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();

      final reviewButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(reviewButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3: Review'), findsOneWidget);

      expect(find.text('Sender'), findsOneWidget);
      expect(find.text('Key word'), findsOneWidget);
      expect(find.text('Amount in this message'), findsOneWidget);
      expect(find.text('debited'), findsOneWidget);
      expect(find.text('500.00'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      await tester.pump();

      final captured = verify(
        () => mockEditorBloc.add(captureAny<TemplateEditorEvent>()),
      ).captured;
      expect(captured.last, isA<SaveTemplateEvent>());

      final event = captured.last as SaveTemplateEvent;
      expect(event.template.triggerWord, 'debited');
      expect(event.template.sourceId, 'src-1');
      expect(event.source.isMonitored, isTrue);
    });

    testWidgets('editing a paused sender\'s format keeps it paused', (
      tester,
    ) async {
      await tester.pumpWidget(
        translated(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<TemplateEditorBloc>.value(value: mockEditorBloc),
                BlocProvider<MessageSourcesBloc>.value(value: mockSourcesBloc),
              ],
              child: InteractiveTemplateBuilder(
                source: testSource.copyWith(isMonitored: false),
                sampleMessage: testSms,
                existingTemplate: ExpenseTemplate(
                  id: 'tmpl-1',
                  sourceId: 'src-1',
                  sampleMessage: testSms.body,
                  triggerWord: 'debited',
                  amountPattern: r'(\d+)',
                  selectedAmount: '500.00',
                  createdAt: DateTime(2026, 1, 1),
                  updatedAt: DateTime(2026, 1, 1),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      final event =
          verify(
                () => mockEditorBloc.add(captureAny<TemplateEditorEvent>()),
              ).captured.last
              as SaveTemplateEvent;
      expect(event.template.id, 'tmpl-1');
      expect(event.source.isMonitored, isFalse);
    });

    testWidgets('back navigation works from Step 2 to Step 1', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3: Choose the amount'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Back'));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3: Choose a key word'), findsOneWidget);
    });

    testWidgets('back navigation works from Step 3 to Step 2', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3: Review'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Back'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3: Choose the amount'), findsOneWidget);
    });

    testWidgets('deselecting a trigger word disables Next button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      var nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNotNull);
      expect(find.text('Choose a word to continue.'), findsNothing);

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();

      nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);
      expect(find.text('Choose a word to continue.'), findsOneWidget);
    });

    testWidgets('Step 3 shows error snackbar on save failure', (tester) async {
      final stateController = StreamController<TemplateEditorState>.broadcast();

      when(
        () => mockEditorBloc.state,
      ).thenReturn(const TemplateEditorInitial());
      when(
        () => mockEditorBloc.stream,
      ).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      verify(() => mockEditorBloc.add(any<TemplateEditorEvent>())).called(1);

      stateController.add(const TemplateEditorSaving());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      stateController.add(const TemplateEditorError('Database error'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          t.messageTemplates.editor.saveFailed(reason: 'Database error'),
        ),
        findsOneWidget,
      );

      await stateController.close();
    });

    testWidgets('step progress indicator updates across steps', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(StepProgressIndicator), findsOneWidget);

      await tester.tap(find.text('debited'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.byType(StepProgressIndicator), findsOneWidget);

      await tester.tap(find.text('500.00'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.byType(StepProgressIndicator), findsOneWidget);
    });
  });
}
