import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/watched_sender.dart';
import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/get_sms_watchlist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMessageTemplateRepository extends Mock
    implements MessageTemplateRepository {}

final _at = DateTime(2026, 10, 1);

MessageSource _source(String id, String name, {bool monitored = true}) =>
    MessageSource(
      id: id,
      contactId: id.toUpperCase(),
      contactName: name,
      isMonitored: monitored,
      createdAt: _at,
      updatedAt: _at,
    );

ExpenseTemplate _format(String id, String sourceId) => ExpenseTemplate(
  id: id,
  sourceId: sourceId,
  sampleMessage: 'Tk 10 debited',
  triggerWord: 'debited',
  amountPattern: r'Tk (\d+)',
  createdAt: _at,
  updatedAt: _at,
);

void main() {
  late MockMessageTemplateRepository repository;
  late GetSmsWatchlist getSmsWatchlist;

  setUp(() {
    repository = MockMessageTemplateRepository();
    getSmsWatchlist = GetSmsWatchlist(repository);
  });

  test('lists only senders with an SMS Format, with their format count, '
      'sorted by name', () async {
    when(() => repository.getMessageSources()).thenAnswer(
      (_) async => Right([
        _source('city', 'city Bank'),
        _source('none', 'No formats'),
        _source('bkash', 'bKash', monitored: false),
        _source('amex', 'Amex'),
      ]),
    );
    when(() => repository.getAllTemplates()).thenAnswer(
      (_) async => Right([
        _format('f1', 'city'),
        _format('f2', 'bkash'),
        _format('f3', 'city'),
        _format('f4', 'amex'),
      ]),
    );

    final result = await getSmsWatchlist(NoParams());
    final senders = result.getOrElse(() => []);

    expect(senders.map((s) => s.source.contactName), [
      'Amex',
      'bKash',
      'city Bank',
    ]);
    expect(senders.map((s) => s.formatCount), [1, 1, 2]);
    expect(senders.map((s) => s.isActive), [true, false, true]);
  });

  test('a failure to read senders is passed on', () async {
    const failure = CacheFailure(message: 'disk');
    when(
      () => repository.getMessageSources(),
    ).thenAnswer((_) async => const Left(failure));

    expect(
      await getSmsWatchlist(NoParams()),
      const Left<Failure, List<WatchedSender>>(failure),
    );
    verifyNever(() => repository.getAllTemplates());
  });

  test('a failure to read formats is passed on', () async {
    const failure = CacheFailure(message: 'disk');
    when(
      () => repository.getMessageSources(),
    ).thenAnswer((_) async => Right([_source('city', 'City')]));
    when(
      () => repository.getAllTemplates(),
    ).thenAnswer((_) async => const Left(failure));

    expect(
      await getSmsWatchlist(NoParams()),
      const Left<Failure, List<WatchedSender>>(failure),
    );
  });
}
