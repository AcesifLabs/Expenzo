import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import 'sync_status.dart';
import 'sync_queue_service.dart';

abstract class FirestoreSyncService {
  Future<Either<Failure, void>> syncData({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  });
  Future<Either<Failure, void>> deleteSync({
    required String collection,
    required String id,
  });
  Stream<SyncStatus> watchSyncStatus();
  Future<Either<Failure, void>> pullChanges();
  Future<Either<Failure, void>> pushChanges();
  Future<Either<Failure, void>> processQueue();
}

class FirestoreSyncServiceImpl implements FirestoreSyncService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final SyncQueueService syncQueueService;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  FirestoreSyncServiceImpl({
    required this.firestore,
    required this.auth,
    required this.syncQueueService,
  });

  String? get _userId => auth.currentUser?.uid;

  CollectionReference get _userCollection {
    if (_userId == null) {
      throw AuthFailure(
        message: 'User not authenticated',
        errorCode: 'AUTH_NOT_AUTHENTICATED',
      );
    }
    return firestore.collection('users').doc(_userId).collection('data');
  }

  void _setStatus(SyncStatus status) {
    _syncStatusController.add(status);
  }

  @override
  Stream<SyncStatus> watchSyncStatus() => _syncStatusController.stream;

  @override
  Future<Either<Failure, void>> syncData({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (_userId == null) {
        return const Left(
          AuthFailure(
            message: 'User not authenticated',
            errorCode: 'AUTH_NOT_AUTHENTICATED',
          ),
        );
      }
      _setStatus(SyncStatus.syncing);
      await _userCollection
          .doc(collection)
          .collection('items')
          .doc(id)
          .set(data);
      _setStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSync({
    required String collection,
    required String id,
  }) async {
    try {
      if (_userId == null) {
        return const Left(
          AuthFailure(
            message: 'User not authenticated',
            errorCode: 'AUTH_NOT_AUTHENTICATED',
          ),
        );
      }
      _setStatus(SyncStatus.syncing);
      await _userCollection
          .doc(collection)
          .collection('items')
          .doc(id)
          .delete();
      _setStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pullChanges() async {
    throw UnimplementedError('pullChanges() not implemented yet');
  }

  @override
  Future<Either<Failure, void>> pushChanges() async {
    throw UnimplementedError('pushChanges() not implemented yet');
  }

  @override
  Future<Either<Failure, void>> processQueue() async {
    throw UnimplementedError('processQueue() not implemented yet');
  }

  void dispose() {
    _syncStatusController.close();
  }
}
