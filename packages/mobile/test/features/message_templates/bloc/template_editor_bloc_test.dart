import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/save_template.dart';
import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class MockSaveTemplate extends Mock implements SaveTemplate {}

class MockMessageTemplateRepository extends Mock
    implements MessageTemplateRepository {}

class _MessageSourceFake extends Fake implements MessageSource {}

class _ExpenseTemplateFake extends Fake implements ExpenseTemplate {}

void main() {
  setUpAll(() {
    registerFallbackValue(_MessageSourceFake());
    registerFallbackValue(_ExpenseTemplateFake());
  });
  late MockSaveTemplate mockSaveTemplate;
  late MockMessageTemplateRepository mockRepository;
  late TemplateEditorBloc bloc;

  final testTemplate = ExpenseTemplate(
    id: 'tmpl-1',
    sourceId: 'src-1',
    sampleMessage: 'Sample message',
    triggerWord: 'trigger',
    amountPattern: r'\d+\.\d{2}',
    categoryId: 'cat-1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final testSource = MessageSource(
    id: 'src-1',
    contactId: 'contact-1',
    contactName: 'Test Source',
    isMonitored: true,
    autoCreateOption: AutoCreateOption.manualOnly,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockSaveTemplate = MockSaveTemplate();
    mockRepository = MockMessageTemplateRepository();
    bloc = TemplateEditorBloc(
      saveTemplateUseCase: mockSaveTemplate,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('SaveTemplateEvent', () {
    test(
      'emits [TemplateEditorSaving, TemplateEditorSaved] on success',
      () async {
        when(
          () => mockRepository.saveMessageSource(any()),
        ).thenAnswer((_) async => Right(testSource));
        when(
          () => mockSaveTemplate(any()),
        ).thenAnswer((_) async => Right(testTemplate));

        final expected = [
          isA<TemplateEditorSaving>(),
          isA<TemplateEditorSaved>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(SaveTemplateEvent(testTemplate, testSource));
      },
    );

    test(
      'emits [TemplateEditorSaving, TemplateEditorError] on save failure',
      () async {
        when(
          () => mockRepository.saveMessageSource(any()),
        ).thenAnswer((_) async => Right(testSource));
        when(
          () => mockSaveTemplate(any()),
        ).thenAnswer((_) async => Left(CacheFailure(message: 'Save failed')));

        final expected = [
          isA<TemplateEditorSaving>(),
          isA<TemplateEditorError>().having(
            (s) => s.message,
            'message',
            t.common.errors.storage,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(SaveTemplateEvent(testTemplate, testSource));
      },
    );
  });

  blocTest<TemplateEditorBloc, TemplateEditorState>(
    'a double tap on Save saves once',
    setUp: () {
      when(
        () => mockRepository.saveMessageSource(any()),
      ).thenAnswer((_) async => Right(testSource));
      when(
        () => mockSaveTemplate(any()),
      ).thenAnswer((_) async => Right(testTemplate));
    },
    build: () => TemplateEditorBloc(
      saveTemplateUseCase: mockSaveTemplate,
      repository: mockRepository,
    ),
    act: (bloc) => bloc
      ..add(SaveTemplateEvent(testTemplate, testSource))
      ..add(SaveTemplateEvent(testTemplate, testSource)),
    expect: () => [isA<TemplateEditorSaving>(), isA<TemplateEditorSaved>()],
    verify: (_) => verify(() => mockSaveTemplate(any())).called(1),
  );

  group('DeleteTemplateEvent', () {
    test(
      'emits [TemplateEditorSaving, TemplateEditorDeleted] on success',
      () async {
        when(
          () => mockRepository.deleteTemplate(any()),
        ).thenAnswer((_) async => const Right(unit));

        final expected = [
          isA<TemplateEditorSaving>(),
          isA<TemplateEditorDeleted>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const DeleteTemplateEvent('tmpl-1'));
      },
    );
  });
}
