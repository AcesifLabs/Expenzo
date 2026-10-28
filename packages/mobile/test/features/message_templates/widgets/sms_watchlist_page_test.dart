import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/watched_sender.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_event.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/sms_watchlist_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/core_screens.dart';
import '../../../support/pump_localized.dart';
import '../../../support/settings_screens.dart';

final _at = DateTime(2026, 10, 1);

WatchedSender _sender(
  String id,
  String name, {
  bool active = true,
  int formats = 1,
}) => WatchedSender(
  source: MessageSource(
    id: id,
    contactId: id.toUpperCase(),
    contactName: name,
    isMonitored: active,
    createdAt: _at,
    updatedAt: _at,
  ),
  formatCount: formats,
);

void main() {
  setUpAll(() => registerFallbackValue(const SmsWatchlistLoadRequested()));

  Future<SmsWatchlistBloc> pump(
    WidgetTester tester,
    SmsWatchlistState state,
  ) async {
    final bloc = mockBloc<MockSmsWatchlistBloc, SmsWatchlistState>(
      MockSmsWatchlistBloc(),
      state,
    );
    await pumpLocalized(
      tester,
      BlocProvider<SmsWatchlistBloc>.value(
        value: bloc,
        child: const Scaffold(body: SmsWatchlistView()),
      ),
    );

    return bloc;
  }

  testWidgets('each sender shows its address, format count and pause state', (
    tester,
  ) async {
    await pump(
      tester,
      SmsWatchlistReady(
        senders: [
          _sender('bkash', 'bKash', formats: 2),
          _sender('city', 'City Bank', active: false),
        ],
      ),
    );

    expect(find.text('bKash'), findsOneWidget);
    expect(find.text('BKASH · 2 SMS formats'), findsOneWidget);
    expect(find.text('CITY · 1 SMS format · Paused'), findsOneWidget);
    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.map((s) => s.value), [true, false]);
  });

  testWidgets('switching a sender off asks the bloc to pause it', (
    tester,
  ) async {
    final sender = _sender('bkash', 'bKash');
    final bloc = await pump(tester, SmsWatchlistReady(senders: [sender]));

    await tester.tap(find.byType(Switch));

    verify(
      () =>
          bloc.add(SmsWatchlistSenderToggled(sender: sender, isActive: false)),
    ).called(1);
  });

  testWidgets('no senders shows a way to add one', (tester) async {
    await pump(tester, const SmsWatchlistReady(senders: []));

    expect(find.text(t.messageTemplates.watchlist.empty), findsOneWidget);
    expect(find.text(t.messageTemplates.watchlist.addSender), findsOneWidget);
  });

  testWidgets('a failed load can be retried', (tester) async {
    final bloc = await pump(tester, const SmsWatchlistError(message: 'disk'));

    expect(find.text(t.messageTemplates.watchlist.loadFailed), findsOneWidget);
    await tester.tap(find.text(t.common.tryAgain));
    verify(() => bloc.add(const SmsWatchlistLoadRequested())).called(1);
  });
}
