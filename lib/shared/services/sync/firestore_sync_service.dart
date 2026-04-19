import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../../../../core/error/failures.dart';
import '../../../features/expenses/domain/entities/expense.dart';
import '../../../features/categories/domain/entities/category.dart' as entities;
import 'sync_status.dart';
import 'conflict_resolver.dart';
import 'sync_queue_service.dart';

abstract class FirestoreSyncService {
  Future<Either<Failure, void>> syncExpense(Expense expense);
  Future<Either<Failure, void>> syncCategory(entities.Category category);
  Future<Either<Failure, void>> deleteExpenseSync(String expenseId);
  Future<Either<Failure, void>> deleteCategorySync(String categoryId);
  Stream<SyncStatus> watchSyncStatus();
  Future<Either<Failure, void>> pullChanges();
  Future<Either<Failure, void>> pushChanges();
  Future<Either<Failure, void>> processQueue();
}

class FirestoreSyncServiceImpl implements FirestoreSyncService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final SyncQueueService syncQueueService;
  final ConflictResolver conflictResolver;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;

  FirestoreSyncServiceImpl({
    required this.firestore,
    required this.auth,
    required this.syncQueueService,
    required this.conflictResolver,
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
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  @override
  Stream<SyncStatus> watchSyncStatus() => _syncStatusController.stream;

  @override
  Future<Either<Failure, void>> syncExpense(Expense expense) async {
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
          .doc('expenses')
          .collection('items')
          .doc(expense.id?.toString())
          .set(_expenseToMap(expense));
      _setStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncCategory(entities.Category category) async {
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
          .doc('categories')
          .collection('items')
          .doc(category.id?.toString())
          .set(_categoryToMap(category));
      _setStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpenseSync(String expenseId) async {
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
          .doc('expenses')
          .collection('items')
          .doc(expenseId)
          .delete();
      _setStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategorySync(String categoryId) async {
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
          .doc('categories')
          .collection('items')
          .doc(categoryId)
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
      // Pull changes from Firestore would be implemented here
      // This is a simplified version - full implementation would fetch and merge
      _setStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pushChanges() async {
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
      // Push changes would be implemented here
      _setStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> processQueue() async {
    try {
      _setStatus(SyncStatus.syncing);
      final queueResult = await syncQueueService.getQueue();
      return queueResult.fold((failure) => Left(failure), (queue) async {
        for (final item in queue) {
          switch (item.entityType) {
            case 'expense':
              // Process expense queue item
              break;
            case 'category':
              // Process category queue item
              break;
          }
          await syncQueueService.removeFromQueue(item.id);
        }
        _setStatus(SyncStatus.success);
        return const Right(null);
      });
    } catch (e) {
      _setStatus(SyncStatus.error);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Map<String, dynamic> _expenseToMap(Expense expense) => {
    'amount': expense.amount,
    'description': expense.description,
    'date': expense.date.toIso8601String(),
    'categoryId': expense.categoryId,
    'source': expense.source.name,
    'sourceId': expense.sourceId,
    'createdAt': expense.createdAt.toIso8601String(),
    'updatedAt': expense.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _categoryToMap(entities.Category category) => {
    'name': category.name,
    'emoji': category.emoji,
    'color': category.color,
    'isDefault': category.isDefault,
    'createdAt': category.createdAt.toIso8601String(),
    'updatedAt': category.updatedAt.toIso8601String(),
  };

  void dispose() {
    _syncStatusController.close();
  }
}
