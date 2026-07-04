// ignore_for_file: unused_import, unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_state.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';

class MockSmsLocalDatasource extends Mock implements SmsLocalDatasource {}

void main() {
  late MockSmsLocalDatasource mockDatasource;
  late ContactSelectorBloc bloc;

  setUp(() {
    mockDatasource = MockSmsLocalDatasource();
    bloc = ContactSelectorBloc(smsDatasource: mockDatasource);
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadContacts', () {
    test(
      'emits [ContactSelectorLoading, ContactSelectorLoaded] on success',
      () async {
        when(
          () => mockDatasource.getSmsBatched(start: 0, count: 200),
        ).thenAnswer((_) async => []);

        final expected = [
          isA<ContactSelectorLoading>(),
          isA<ContactSelectorLoaded>().having(
            (s) => s.contacts,
            'contacts',
            isEmpty,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(LoadContacts());
      },
    );

    test(
      'emits [ContactSelectorLoading, ContactSelectorError] on failure',
      () async {
        when(
          () => mockDatasource.getSmsBatched(start: 0, count: 200),
        ).thenThrow(Exception('Database error'));

        final expected = [
          isA<ContactSelectorLoading>(),
          isA<ContactSelectorError>().having(
            (s) => s.message,
            'message',
            'Exception: Database error',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(LoadContacts());
      },
    );
  });
}
