import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/get_message_sources.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/save_message_source.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_state.dart';

class MockGetMessageSources extends Mock implements GetMessageSources {}

class MockSaveMessageSource extends Mock implements SaveMessageSource {}

void main() {
  late MockGetMessageSources mockGetMessageSources;
  late MockSaveMessageSource mockSaveMessageSource;
  late MessageSourcesBloc bloc;

  final testSource = MessageSource(
    id: 'src-1',
    contactId: 'contact-1',
    contactName: 'Test Bank',
    isMonitored: true,
    autoCreateOption: AutoCreateOption.manualOnly,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockGetMessageSources = MockGetMessageSources();
    mockSaveMessageSource = MockSaveMessageSource();
    bloc = MessageSourcesBloc(
      getMessageSources: mockGetMessageSources,
      saveMessageSource: mockSaveMessageSource,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadMessageSources', () {
    test(
      'emits [MessageSourcesLoading, MessageSourcesLoaded] on success',
      () async {
        when(
          () => mockGetMessageSources(any()),
        ).thenAnswer((_) async => Right([testSource]));

        final expected = [
          isA<MessageSourcesLoading>(),
          isA<MessageSourcesLoaded>().having(
            (s) => s.sources.length,
            'sources length',
            1,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(LoadMessageSources());
      },
    );

    test(
      'emits [MessageSourcesLoading, MessageSourcesError] on failure',
      () async {
        when(() => mockGetMessageSources(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Failed to load')),
        );

        final expected = [
          isA<MessageSourcesLoading>(),
          isA<MessageSourcesError>().having(
            (s) => s.message,
            'message',
            'Failed to load',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(LoadMessageSources());
      },
    );
  });
}
