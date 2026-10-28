import 'dart:convert';

import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cached.dart';
import '../../domain/entities/group_summary.dart';
import '../../domain/entities/my_group.dart';
import '../models/family_json.dart';

class FamilyLocalDatasource {
  final SharedPreferences prefs;

  final String? Function() currentUserId;

  static const groupKeyPrefix = 'family_group_';
  static const summaryKeyPrefix = 'family_summary_';

  const FamilyLocalDatasource({
    required this.prefs,
    required this.currentUserId,
  });

  Cached<MyGroup?>? readGroup() => _read(
    groupKeyPrefix,
    (data) => data == null ? null : myGroupFromJson(data),
  );

  Future<void> writeGroup(MyGroup? group, DateTime fetchedAt) => _write(
    groupKeyPrefix,
    group == null ? null : myGroupToJson(group),
    fetchedAt,
  );

  Cached<GroupSummary>? readSummary() {
    final cached = _read(
      summaryKeyPrefix,
      (data) => data == null ? null : groupSummaryFromJson(data),
    );
    if (cached case Cached(value: final summary?, :final fetchedAt)) {
      return Cached(summary, fetchedAt: fetchedAt);
    }

    return null;
  }

  Future<void> writeSummary(GroupSummary summary, DateTime fetchedAt) =>
      _write(summaryKeyPrefix, groupSummaryToJson(summary), fetchedAt);

  Future<void> clearSummary() async {
    final key = _key(summaryKeyPrefix);
    if (key != null) await prefs.remove(key);
  }

  String? _key(String prefix) {
    final userId = currentUserId();

    return userId == null ? null : '$prefix$userId';
  }

  Cached<T>? _read<T>(String prefix, T Function(Json? data) parse) {
    final key = _key(prefix);
    final raw = key == null ? null : prefs.getString(key);
    if (key == null || raw == null) return null;
    try {
      final stored = jsonDecode(raw) as Json;

      return Cached(
        parse(stored['data'] as Json?),
        fetchedAt: DateTime.parse(stored['fetchedAt'] as String),
      );
    } on Object catch (e, s) {
      appLogger.error('Dropping unreadable family cache $prefix', e, s);
      prefs.remove(key);

      return null;
    }
  }

  Future<void> _write(String prefix, Json? data, DateTime fetchedAt) async {
    final key = _key(prefix);
    if (key == null) return;
    await prefs.setString(
      key,
      jsonEncode({
        'fetchedAt': fetchedAt.toUtc().toIso8601String(),
        'data': data,
      }),
    );
  }
}
