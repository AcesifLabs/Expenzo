import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/watched_sender.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/get_sms_watchlist.dart';
import 'package:expense_tracker/features/message_templates/domain/usecases/save_message_source.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSmsWatchlist extends Mock implements GetSmsWatchlist {}

class MockSaveMessageSource extends Mock implements SaveMessageSource {}

class _NoParamsFake extends Fake implements NoParams {}

class _MessageSourceFake extends Fake implements MessageSource {}

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    registerFallbackValue(_NoParamsFake());
    registerFallbackValue(_MessageSourceFake());
  });

  late MockGetSmsWatchlist getSmsWatchlist;
  late MockSaveMessageSource saveMessageSource;

  final at = DateTime(2026, 10, 1);
  final sender = WatchedSender(
    source: MessageSource(
      id: 'city',
      contactId: 'CITY',
      contactName: 'City Bank',
      isMonitored: true,
      createdAt: at,
      updatedAt: at,
    ),
    formatCount: 2,
  );
  final paused = WatchedSender(
    source: sender.source.copyWith(isMonitored: false),
    formatCount: 2,
  );

  setUp(() {
    getSmsWatchlist = MockGetSmsWatchlist();
    saveMessageSource = MockSaveMessageSource();
  });

  SmsWatchlistBloc build() => SmsWatchlistBloc(
    getSmsWatchlist: getSmsWatchlist,
    saveMessageSource: saveMessageSource,
  );

  blocTest<SmsWatchlistBloc, SmsWatchlistState>(
    'loading shows the senders',
    setUp: () => when(
      () => getSmsWatchlist(any()),
    ).thenAnswer((_) async => Right([sender])),
    build: build,
    act: (bloc) => bloc.add(const SmsWatchlistLoadRequested()),
    expect: () => [
      SmsWatchlistReady(senders: [sender]),
    ],
  );

  blocTest<SmsWatchlistBloc, SmsWatchlistState>(
    'a failed load shows an error',
    setUp: () => when(
      () => getSmsWatchlist(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk'))),
    build: build,
    act: (bloc) => bloc.add(const SmsWatchlistLoadRequested()),
    expect: () => [isA<SmsWatchlistError>()],
  );

  blocTest<SmsWatchlistBloc, SmsWatchlistState>(
    'pausing a sender saves it unmonitored and reloads the list',
    setUp: () {
      when(() => saveMessageSource(any())).thenAnswer(
        (inv) async => Right(inv.positionalArguments.first as MessageSource),
      );
      when(
        () => getSmsWatchlist(any()),
      ).thenAnswer((_) async => Right([paused]));
    },
    build: build,
    act: (bloc) =>
        bloc.add(SmsWatchlistSenderToggled(sender: sender, isActive: false)),
    expect: () => [
      SmsWatchlistReady(senders: [paused]),
    ],
    verify: (_) {
      final saved =
          verify(() => saveMessageSource(captureAny())).captured.single
              as MessageSource;
      expect(saved.id, 'city');
      expect(saved.isMonitored, isFalse);
    },
  );

  blocTest<SmsWatchlistBloc, SmsWatchlistState>(
    'a failed save shows an error and does not reload',
    setUp: () => when(
      () => saveMessageSource(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk'))),
    build: build,
    act: (bloc) =>
        bloc.add(SmsWatchlistSenderToggled(sender: sender, isActive: false)),
    expect: () => [isA<SmsWatchlistError>()],
    verify: (_) => verifyNever(() => getSmsWatchlist(any())),
  );

  blocTest<SmsWatchlistBloc, SmsWatchlistState>(
    'a failed save keeps the list and reports the error once',
    setUp: () => when(
      () => saveMessageSource(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk'))),
    build: build,
    seed: () => SmsWatchlistReady(senders: [sender]),
    act: (bloc) =>
        bloc.add(SmsWatchlistSenderToggled(sender: sender, isActive: false)),
    expect: () => [
      isA<SmsWatchlistReady>()
          .having((s) => s.senders, 'senders', [sender])
          .having((s) => s.toggleError, 'toggleError', isNotEmpty),
    ],
    verify: (_) => verifyNever(() => getSmsWatchlist(any())),
  );
}
