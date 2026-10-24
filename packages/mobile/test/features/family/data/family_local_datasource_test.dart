import 'package:expense_tracker/features/family/data/datasources/family_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/factories/family_factory.dart';

void main() {
  late SharedPreferences prefs;
  String? uid;
  final fetchedAt = DateTime.utc(2026, 4, 15, 12);

  FamilyLocalDatasource local() =>
      FamilyLocalDatasource(prefs: prefs, currentUserId: () => uid);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    uid = 'uid-a';
  });

  test('writes and reads the group with its fetch time', () async {
    await local().writeGroup(makeMyGroup(), fetchedAt);

    final cached = local().readGroup();
    expect(cached?.value, makeMyGroup());
    expect(cached?.fetchedAt, fetchedAt);
    expect(cached?.fromCache, isFalse);
  });

  test('a cached "not in a group" reads back as a cached null', () async {
    await local().writeGroup(null, fetchedAt);

    final cached = local().readGroup();
    expect(cached, isNotNull);
    expect(cached?.value, isNull);
  });

  test('keeps each account apart', () async {
    await local().writeGroup(makeMyGroup(), fetchedAt);
    uid = 'uid-b';

    expect(local().readGroup(), isNull);
  });

  test('drops corrupt JSON', () async {
    await prefs.setString(
      '${FamilyLocalDatasource.groupKeyPrefix}uid-a',
      '{oops',
    );

    expect(local().readGroup(), isNull);
    expect(
      prefs.containsKey('${FamilyLocalDatasource.groupKeyPrefix}uid-a'),
      isFalse,
    );
  });

  test('signed out reads nothing and writes nothing', () async {
    uid = null;
    await local().writeGroup(makeMyGroup(), fetchedAt);
    await local().writeSummary(makeGroupSummary(), fetchedAt);

    expect(local().readGroup(), isNull);
    expect(prefs.getKeys(), isEmpty);
  });

  test('writes, reads and clears the summary', () async {
    await local().writeSummary(makeGroupSummary(), fetchedAt);
    expect(local().readSummary()?.value, makeGroupSummary());

    await local().clearSummary();
    expect(local().readSummary(), isNull);
  });
}
