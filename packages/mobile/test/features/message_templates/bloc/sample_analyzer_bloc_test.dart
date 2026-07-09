import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sample_analyzer_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sample_analyzer_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sample_analyzer_state.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';

class MockSmsLocalDatasource extends Mock implements SmsLocalDatasource {}

class MockMessageTemplateRepository extends Mock
    implements MessageTemplateRepository {}

class _ExpenseTemplateFake extends Fake implements ExpenseTemplate {}

void main() {
  setUpAll(() {
    registerFallbackValue(_ExpenseTemplateFake());
  });

  late MockSmsLocalDatasource mockSms;
  late MockMessageTemplateRepository mockRepo;
  late StreamController<List<ExpenseTemplate>> watcherController;
  late SampleAnalyzerBloc bloc;

  final testMessage = SmsMessage(
    id: 'sms-1',
    address: 'bKash',
    body: 'Rs.500.00 debited from A/C XX1234',
    date: DateTime(2026, 7, 5),
    read: true,
    type: SmsType.received,
  );

  final matchingMessage = SmsMessage(
    id: 'sms-2',
    address: 'bKash',
    body: 'Rs.700.00 debited from A/C XX5678',
    date: DateTime(2026, 7, 6),
    read: true,
    type: SmsType.received,
  );

  final nonMatchingMessage = SmsMessage(
    id: 'sms-3',
    address: 'bKash',
    body: 'Available balance is Rs.700.00 in A/C XX5678',
    date: DateTime(2026, 7, 7),
    read: true,
    type: SmsType.received,
  );

  final testTemplate = ExpenseTemplate(
    id: 'tmpl-1',
    sourceId: 'src-1',
    sampleMessage: testMessage.body,
    triggerWord: 'debited',
    amountPattern: r'\d+\.\d{2}',
    selectedAmount: '500.00',
    categoryId: 'cat-1',
    createdAt: DateTime(2026, 7, 5),
    updatedAt: DateTime(2026, 7, 5),
  );

  setUp(() async {
    mockSms = MockSmsLocalDatasource();
    mockRepo = MockMessageTemplateRepository();
    watcherController = StreamController<List<ExpenseTemplate>>.broadcast();

    when(
      () => mockSms.getSmsBatched(
        address: any(named: 'address'),
        start: any(named: 'start'),
        count: any(named: 'count'),
      ),
    ).thenAnswer(
      (_) async => [testMessage, matchingMessage, nonMatchingMessage],
    );
    when(
      () => mockRepo.watchTemplatesForSource(any()),
    ).thenAnswer((_) => watcherController.stream);

    bloc = SampleAnalyzerBloc(
      smsDatasource: mockSms,
      templateRepository: mockRepo,
    );
  });

  tearDown(() async {
    await bloc.close();
    await watcherController.close();
  });

  Future<void> pumpBloc() async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }

  /// Dispatches `LoadSamples` AND pushes the initial Drift-watcher
  /// snapshot so the bloc's `await watchTemplatesForSource(...).first`
  /// resolves and the first `SampleAnalyzerLoaded` state carries the
  /// seeded `templatesBySample` for `testMessage.body`.
  Future<void> loadSamplesWithTemplates() async {
    bloc.add(const LoadSamples(contactId: 'bKash', sourceId: 'src-1'));
    await pumpBloc();
    watcherController.add([testTemplate]);
    await pumpBloc();
  }

  group('LoadSamples', () {
    test(
      'watches templates by source id and exposes sender-wide message matches',
      () async {
        final captured = <SampleAnalyzerState>[];
        final sub = bloc.stream.listen(captured.add);

        await loadSamplesWithTemplates();
        await sub.cancel();

        verify(() => mockRepo.watchTemplatesForSource('src-1')).called(1);
        expect(captured.first, isA<SampleAnalyzerLoading>());
        final loaded =
            captured.firstWhere((s) => s is SampleAnalyzerLoaded)
                as SampleAnalyzerLoaded;
        expect(loaded.messages, [
          nonMatchingMessage,
          matchingMessage,
          testMessage,
        ]);
        expect(loaded.templatesBySample.containsKey(testMessage.body), isTrue);
        expect(loaded.templatesBySample[testMessage.body]?.id, 'tmpl-1');
        expect(
          loaded.matchedTemplatesByMessageBody[matchingMessage.body]?.id,
          'tmpl-1',
        );
        expect(
          loaded.matchedTemplatesByMessageBody.containsKey(
            nonMatchingMessage.body,
          ),
          isFalse,
        );
      },
    );
  });

  group('TemplateDeleted', () {
    test(
      'captures the snapshot as pendingDeletion and delegates to repo',
      () async {
        when(
          () => mockRepo.deleteTemplate(any()),
        ).thenAnswer((_) async => const Right(unit));

        await loadSamplesWithTemplates();

        bloc.add(TemplateDeleted(testTemplate));
        await pumpBloc();

        verify(() => mockRepo.deleteTemplate('tmpl-1')).called(1);
        final state = bloc.state as SampleAnalyzerLoaded;
        expect(state.pendingDeletion?.id, 'tmpl-1');
      },
    );

    test(
      'preserves Loaded state and surfaces lastError when delete throws',
      () async {
        when(
          () => mockRepo.deleteTemplate(any()),
        ).thenThrow(Exception('db down'));

        await loadSamplesWithTemplates();

        bloc.add(TemplateDeleted(testTemplate));
        await pumpBloc();

        final state = bloc.state as SampleAnalyzerLoaded;
        // Loaded survives — message list and template map intact.
        expect(state.messages, [
          nonMatchingMessage,
          matchingMessage,
          testMessage,
        ]);
        expect(state.templatesBySample.containsKey(testMessage.body), isTrue);
        // PendingDeletion cleared and the failure surfaced via lastError.
        expect(state.pendingDeletion, isNull);
        expect(state.lastError, contains('Could not delete template'));
      },
    );
  });

  group('TemplateDeletionUndone', () {
    test(
      're-inserts via repo and clears pendingDeletion when no conflict',
      () async {
        when(
          () => mockRepo.deleteTemplate(any()),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => mockRepo.saveTemplate(any()),
        ).thenAnswer((_) async => Right(testTemplate));

        await loadSamplesWithTemplates();

        bloc.add(TemplateDeleted(testTemplate));
        await pumpBloc();

        // Simulate the Drift watcher firing the post-delete snapshot
        // (template removed from the source). Without this tick the
        // `templatesBySample` map would still hold the deleted entry,
        // the conflict guard would fire falsely, and the undo would be
        // dropped.
        watcherController.add(const <ExpenseTemplate>[]);
        await pumpBloc();

        bloc.add(TemplateDeletionUndone(testTemplate));
        await pumpBloc();

        verify(() => mockRepo.deleteTemplate('tmpl-1')).called(1);
        verify(() => mockRepo.saveTemplate(testTemplate)).called(1);

        final state = bloc.state as SampleAnalyzerLoaded;
        expect(state.pendingDeletion, isNull);
      },
    );

    test(
      'drops undo silently when a template already covers the sample',
      () async {
        // Kitchen-sink scenario: delete T1, the Drift watcher fires
        // with a fresh replacement T2 for the same sampleMessage, then
        // the user taps Undo on the in-flight SnackBar. Bloc must NOT
        // call saveTemplate because the conflict guard has already
        // detected the new entry.
        final replacement = testTemplate.copyWith(
          id: 'tmpl-2',
          sourceId: testTemplate.sourceId,
          sampleMessage: testTemplate.sampleMessage,
          triggerWord: testTemplate.triggerWord,
          amountPattern: testTemplate.amountPattern,
          selectedAmount: testTemplate.selectedAmount,
          categoryId: testTemplate.categoryId,
          createdAt: testTemplate.createdAt,
          updatedAt: DateTime(2026, 7, 6),
        );

        when(
          () => mockRepo.deleteTemplate(any()),
        ).thenAnswer((_) async => const Right(unit));

        await loadSamplesWithTemplates();

        bloc.add(TemplateDeleted(testTemplate));
        await pumpBloc();

        watcherController.add([replacement]);
        await pumpBloc();

        bloc.add(TemplateDeletionUndone(testTemplate));
        await pumpBloc();

        verifyNever(() => mockRepo.saveTemplate(any()));
        final state = bloc.state as SampleAnalyzerLoaded;
        expect(state.pendingDeletion, isNull);
        expect(state.templatesBySample[testMessage.body]?.id, 'tmpl-2');
      },
    );

    test('preserves Loaded state with lastError when restore fails', () async {
      when(
        () => mockRepo.deleteTemplate(any()),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => mockRepo.saveTemplate(any()),
      ).thenThrow(Exception('save failed'));

      await loadSamplesWithTemplates();

      bloc.add(TemplateDeleted(testTemplate));
      await pumpBloc();

      // Post-delete watcher tick so the conflict guard doesn't fire.
      watcherController.add(const <ExpenseTemplate>[]);
      await pumpBloc();

      bloc.add(TemplateDeletionUndone(testTemplate));
      await pumpBloc();

      final state = bloc.state as SampleAnalyzerLoaded;
      expect(state.pendingDeletion, isNull);
      expect(state.lastError, contains('Could not restore template'));
    });
  });

  group('TemplateDeletionExpired', () {
    test('clears pendingDeletion', () async {
      when(
        () => mockRepo.deleteTemplate(any()),
      ).thenAnswer((_) async => const Right(unit));

      await loadSamplesWithTemplates();

      bloc.add(TemplateDeleted(testTemplate));
      await pumpBloc();

      bloc.add(const TemplateDeletionExpired());
      await pumpBloc();

      final state = bloc.state as SampleAnalyzerLoaded;
      expect(state.pendingDeletion, isNull);
    });

    test('is a no-op when there is no pendingDeletion', () async {
      await loadSamplesWithTemplates();

      bloc.add(const TemplateDeletionExpired());
      await pumpBloc();

      final state = bloc.state as SampleAnalyzerLoaded;
      expect(state.pendingDeletion, isNull);
    });
  });

  group('LastErrorDismissed', () {
    test('clears lastError after a save-failure', () async {
      when(
        () => mockRepo.deleteTemplate(any()),
      ).thenThrow(Exception('db down'));

      await loadSamplesWithTemplates();

      bloc.add(TemplateDeleted(testTemplate));
      await pumpBloc();

      expect((bloc.state as SampleAnalyzerLoaded).lastError, isNotNull);

      bloc.add(const LastErrorDismissed());
      await pumpBloc();

      final state = bloc.state as SampleAnalyzerLoaded;
      expect(state.lastError, isNull);
    });

    test('is a no-op when there is no lastError', () async {
      await loadSamplesWithTemplates();

      bloc.add(const LastErrorDismissed());
      await pumpBloc();

      final state = bloc.state as SampleAnalyzerLoaded;
      expect(state.lastError, isNull);
    });
  });
}
