import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/source_types.dart';

abstract class DeepLinkService {
  Stream<DeepLink?> get onDeepLinkReceived;
  Future<void> handleDeepLink(Uri uri);
  void dispose();
}

class DeepLink {
  final DeepLinkPath path;
  final String? id;
  final Map<String, String> queryParams;

  const DeepLink({required this.path, this.id, this.queryParams = const {}});
}

class DeepLinkServiceImpl implements DeepLinkService {
  final _deepLinkController = StreamController<DeepLink?>.broadcast();
  StreamSubscription? _uriSubscription;

  @override
  Stream<DeepLink?> get onDeepLinkReceived => _deepLinkController.stream;

  DeepLinkServiceImpl();

  @override
  Future<void> handleDeepLink(Uri uri) async {
    final deepLink = _parseUri(uri);
    _deepLinkController.add(deepLink);
  }

  @override
  void dispose() {
    _uriSubscription?.cancel();
    _deepLinkController.close();
  }

  DeepLink _parseUri(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return const DeepLink(path: DeepLinkPath.unknown);
    }

    switch (pathSegments.first) {
      case 'budgets':
        if (pathSegments.length > 1) {
          return DeepLink(
            path: DeepLinkPath.budgetDetail,
            id: pathSegments[1],
            queryParams: uri.queryParameters,
          );
        }
        return const DeepLink(path: DeepLinkPath.budgets);

      case 'expenses':
        if (pathSegments.length > 1) {
          return DeepLink(
            path: DeepLinkPath.expenseDetail,
            id: pathSegments[1],
            queryParams: uri.queryParameters,
          );
        }
        return const DeepLink(path: DeepLinkPath.expenses);

      case 'scan':
        if (pathSegments.length > 1) {
          if (pathSegments[1] == ExpenseSource.sms.name) {
            return const DeepLink(path: DeepLinkPath.scanSms);
          } else if (pathSegments[1] == ExpenseSource.email.name) {
            return const DeepLink(path: DeepLinkPath.scanEmail);
          }
        }
        return const DeepLink(path: DeepLinkPath.scanSms);

      case 'notifications':
        return const DeepLink(path: DeepLinkPath.notifications);

      case 'recurring':
        if (pathSegments.length > 1) {
          return DeepLink(
            path: DeepLinkPath.recurringDetail,
            id: pathSegments[1],
            queryParams: uri.queryParameters,
          );
        }
        return const DeepLink(path: DeepLinkPath.recurring);

      default:
        return const DeepLink(path: DeepLinkPath.unknown);
    }
  }
}

class DeepLinkHandler {
  final GlobalKey<NavigatorState> navigatorKey;

  DeepLinkHandler({required this.navigatorKey});
}

enum DeepLinkPath {
  budgets,
  budgetDetail,
  expenses,
  expenseDetail,
  scanSms,
  scanEmail,
  notifications,
  recurring,
  recurringDetail,
  unknown,
}
