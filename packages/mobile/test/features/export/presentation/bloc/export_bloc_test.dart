import 'dart:async';

import 'package:bloc_test/bloc_test.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/export/domain/entities/export_file.dart';
import 'package:expense_tracker/features/export/domain/entities/export_request.dart';
import 'package:expense_tracker/features/export/domain/usecases/export_data.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_bloc.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_event.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/services/file_share_service.dart';

class _MockExportData extends Mock implements ExportData {}

class _MockShare extends Mock implements FileShareService {}

void main() {
  const file = ExportFile(
    path: '/tmp/export.zip',
    mimeType: ExportFile.zipMimeType,
  );

  late _MockExportData exportData;
  late _MockShare share;
  late ExportBloc bloc;

  setUpAll(() {
    registerFallbackValue(
      const ExportRequest(range: ExportRange.allTime, contents: {}),
    );
  });

  setUp(() {
    exportData = _MockExportData();
    share = _MockShare();
    bloc = ExportBloc(exportData: exportData, shareService: share);
  });

  tearDown(() => bloc.close());

  void stubShare(Future<ShareOutcome> Function() answer) {
    when(
      () => share.shareFile(
        any(),
        mimeType: any(named: 'mimeType'),
        subject: any(named: 'subject'),
      ),
    ).thenAnswer((_) => answer());
  }

  void verifyNeverShared() => verifyNever(
    () => share.shareFile(
      any(),
      mimeType: any(named: 'mimeType'),
      subject: any(named: 'subject'),
    ),
  );

  TypeMatcher<ExportState> hasStatus(ExportStatus status) =>
      isA<ExportState>().having((s) => s.status, 'status', status);

  test('initial state: all time, all contents, idle, can export', () {
    expect(bloc.state.range, ExportRange.allTime);
    expect(bloc.state.contents, ExportContent.values.toSet());
    expect(bloc.state.status, ExportStatus.idle);
    expect(bloc.state.canExport, isTrue);
  });

  test('a preset range is selected; custom via ExportRangeSelected is '
      'ignored', () async {
    bloc.add(const ExportRangeSelected(ExportRange.lastThreeMonths));
    await pumpEventQueue();
    expect(bloc.state.range, ExportRange.lastThreeMonths);

    bloc.add(const ExportRangeSelected(ExportRange.custom));
    await pumpEventQueue();
    expect(bloc.state.range, ExportRange.lastThreeMonths);
  });

  test('a custom pick sets the range and dates; a second pick replaces '
      'them; start after end is ignored', () async {
    bloc.add(
      ExportCustomRangePicked(DateTime(2026, 3, 1), DateTime(2026, 3, 9)),
    );
    await pumpEventQueue();
    expect(bloc.state.range, ExportRange.custom);
    expect(bloc.state.customStart, DateTime(2026, 3, 1));

    bloc.add(
      ExportCustomRangePicked(DateTime(2026, 4, 1), DateTime(2026, 4, 2)),
    );
    await pumpEventQueue();
    expect(bloc.state.customStart, DateTime(2026, 4, 1));
    expect(bloc.state.customEnd, DateTime(2026, 4, 2));

    bloc.add(
      ExportCustomRangePicked(DateTime(2026, 5, 2), DateTime(2026, 5, 1)),
    );
    await pumpEventQueue();
    expect(bloc.state.customStart, DateTime(2026, 4, 1));
  });

  test('turning every content off disables export', () async {
    for (final content in ExportContent.values) {
      bloc.add(ExportContentToggled(content, included: false));
    }
    await pumpEventQueue();
    expect(bloc.state.contents, isEmpty);
    expect(bloc.state.canExport, isFalse);

    bloc.add(const ExportRequested());
    await pumpEventQueue();
    verifyNever(() => exportData(any()));
  });

  test('a successful export shares the file once', () async {
    when(() => exportData(any())).thenAnswer((_) async => const Right(file));
    stubShare(() async => ShareOutcome.dismissed);

    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        hasStatus(ExportStatus.exporting),
        hasStatus(ExportStatus.shared),
      ]),
    );
    bloc.add(const ExportRequested());
    await states;

    verify(
      () => share.shareFile(
        file.path,
        mimeType: file.mimeType,
        subject: t.settings.export.shareSubject,
      ),
    ).called(1);
  });

  test(
    'an empty range ends in empty with the message and does not share',
    () async {
      when(
        () => exportData(any()),
      ).thenAnswer((_) async => const Left(EmptyExportFailure()));

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          hasStatus(ExportStatus.exporting),
          hasStatus(ExportStatus.empty).having(
            (s) => s.errorMessage,
            'errorMessage',
            'No transactions in this range',
          ),
        ]),
      );
      bloc.add(const ExportRequested());
      await states;
      verifyNeverShared();
    },
  );

  blocTest<ExportBloc, ExportState>(
    'an export failure shows the storage message and does not share',
    setUp: () => when(
      () => exportData(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk full'))),
    build: () => bloc,
    act: (bloc) => bloc.add(const ExportRequested()),
    expect: () => [
      hasStatus(ExportStatus.exporting),
      hasStatus(
        ExportStatus.failed,
      ).having((s) => s.errorMessage, 'errorMessage', t.common.errors.storage),
    ],
    verify: (_) => verifyNeverShared(),
  );

  blocTest<ExportBloc, ExportState>(
    'a share that throws ends in failed',
    setUp: () {
      when(() => exportData(any())).thenAnswer((_) async => const Right(file));
      stubShare(() async => throw Exception('no activity'));
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ExportRequested()),
    expect: () => [
      hasStatus(ExportStatus.exporting),
      hasStatus(
        ExportStatus.failed,
      ).having((s) => s.errorMessage, 'errorMessage', t.common.errors.generic),
    ],
  );

  test('a choice after a final status resets to idle', () async {
    when(
      () => exportData(any()),
    ).thenAnswer((_) async => const Left(EmptyExportFailure()));
    bloc.add(const ExportRequested());
    await pumpEventQueue();
    expect(bloc.state.status, ExportStatus.empty);

    bloc.add(const ExportRangeSelected(ExportRange.thisYear));
    await pumpEventQueue();
    expect(bloc.state.status, ExportStatus.idle);
    expect(bloc.state.errorMessage, isNull);
  });

  test('choices are ignored while an export runs', () async {
    final result = Completer<Either<Failure, ExportFile>>();
    when(() => exportData(any())).thenAnswer((_) => result.future);
    stubShare(() async => ShareOutcome.shared);

    bloc.add(const ExportRequested());
    await pumpEventQueue();
    bloc
      ..add(const ExportRangeSelected(ExportRange.thisYear))
      ..add(ExportCustomRangePicked(DateTime(2026, 3, 1), DateTime(2026, 3, 2)))
      ..add(const ExportContentToggled(ExportContent.budgets, included: false));
    await pumpEventQueue();

    expect(bloc.state.status, ExportStatus.exporting);
    expect(bloc.state.range, ExportRange.allTime);
    expect(bloc.state.contents, ExportContent.values.toSet());

    result.complete(const Right(file));
    await pumpEventQueue();
    expect(bloc.state.status, ExportStatus.shared);
  });
}
