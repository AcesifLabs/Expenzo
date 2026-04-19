import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';

enum SyncOperation { create, update, delete }

class SyncQueueItem {
  final String id;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation.name,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
    id: json['id'] as String,
    entityType: json['entityType'] as String,
    entityId: json['entityId'] as String,
    operation: SyncOperation.values.firstWhere(
      (e) => e.name == json['operation'],
    ),
    data: json['data'] as Map<String, dynamic>,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

abstract class SyncQueueService {
  Future<Either<Failure, void>> addToQueue(SyncQueueItem item);
  Future<Either<Failure, List<SyncQueueItem>>> getQueue();
  Future<Either<Failure, void>> removeFromQueue(String id);
  Future<Either<Failure, void>> clearQueue();
  Future<Either<Failure, int>> getQueueCount();
}

class SyncQueueServiceImpl implements SyncQueueService {
  static const _queueKey = 'sync_queue';
  final SharedPreferences sharedPreferences;

  SyncQueueServiceImpl({required this.sharedPreferences});

  @override
  Future<Either<Failure, void>> addToQueue(SyncQueueItem item) async {
    try {
      final queue = await _loadQueue();
      queue.add(item);
      await _saveQueue(queue);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SyncQueueItem>>> getQueue() async {
    try {
      final queue = await _loadQueue();
      return Right(queue);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromQueue(String id) async {
    try {
      final queue = await _loadQueue();
      queue.removeWhere((item) => item.id == id);
      await _saveQueue(queue);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearQueue() async {
    try {
      await sharedPreferences.remove(_queueKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getQueueCount() async {
    try {
      final queue = await _loadQueue();
      return Right(queue.length);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<List<SyncQueueItem>> _loadQueue() async {
    final jsonString = sharedPreferences.getString(_queueKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => SyncQueueItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveQueue(List<SyncQueueItem> queue) async {
    final jsonList = queue.map((e) => e.toJson()).toList();
    await sharedPreferences.setString(_queueKey, json.encode(jsonList));
  }
}
