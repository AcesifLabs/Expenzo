import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracker/shared/services/deep_link_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Deep Link Integration Tests', () {
    late DeepLinkServiceImpl deepLinkService;

    setUp(() {
      deepLinkService = DeepLinkServiceImpl();
    });

    tearDown(() {
      deepLinkService.dispose();
    });

    test(
      'budgetDeepLink_flow parses budget detail deep link correctly',
      () async {
        final uri = Uri.parse('expenso://budgets/budget_123');

        await deepLinkService.handleDeepLink(uri);

        final deepLink = await deepLinkService.onDeepLinkReceived.first;

        expect(deepLink, isNotNull);
        expect(deepLink!.path, equals(DeepLinkPath.budgetDetail));
        expect(deepLink.id, equals('budget_123'));
      },
    );

    test(
      'budgetListDeepLink_flow parses budget list deep link correctly',
      () async {
        final uri = Uri.parse('expenso://budgets');

        await deepLinkService.handleDeepLink(uri);

        final deepLink = await deepLinkService.onDeepLinkReceived.first;

        expect(deepLink, isNotNull);
        expect(deepLink!.path, equals(DeepLinkPath.budgets));
      },
    );

    test('smsScanDeepLink_flow parses SMS scan deep link correctly', () async {
      final uri = Uri.parse('expenso://scan/sms');

      await deepLinkService.handleDeepLink(uri);

      final deepLink = await deepLinkService.onDeepLinkReceived.first;

      expect(deepLink, isNotNull);
      expect(deepLink!.path, equals(DeepLinkPath.scanSms));
    });

    test(
      'emailScanDeepLink_flow parses email scan deep link correctly',
      () async {
        final uri = Uri.parse('expenso://scan/email');

        await deepLinkService.handleDeepLink(uri);

        final deepLink = await deepLinkService.onDeepLinkReceived.first;

        expect(deepLink, isNotNull);
        expect(deepLink!.path, equals(DeepLinkPath.scanEmail));
      },
    );

    test('scanDeepLinkDefault_flow defaults to SMS scan', () async {
      final uri = Uri.parse('expenso://scan');

      await deepLinkService.handleDeepLink(uri);

      final deepLink = await deepLinkService.onDeepLinkReceived.first;

      expect(deepLink, isNotNull);
      expect(deepLink!.path, equals(DeepLinkPath.scanSms));
    });

    test('expensesDeepLink_flow parses expenses deep link correctly', () async {
      final uri = Uri.parse('expenso://expenses');

      await deepLinkService.handleDeepLink(uri);

      final deepLink = await deepLinkService.onDeepLinkReceived.first;

      expect(deepLink, isNotNull);
      expect(deepLink!.path, equals(DeepLinkPath.expenses));
    });

    test(
      'expenseDetailDeepLink_flow parses expense detail deep link correctly',
      () async {
        final uri = Uri.parse('expenso://expenses/expense_456');

        await deepLinkService.handleDeepLink(uri);

        final deepLink = await deepLinkService.onDeepLinkReceived.first;

        expect(deepLink, isNotNull);
        expect(deepLink!.path, equals(DeepLinkPath.expenseDetail));
        expect(deepLink.id, equals('expense_456'));
      },
    );

    test(
      'recurringDeepLink_flow parses recurring list deep link correctly',
      () async {
        final uri = Uri.parse('expenso://recurring');

        await deepLinkService.handleDeepLink(uri);

        final deepLink = await deepLinkService.onDeepLinkReceived.first;

        expect(deepLink, isNotNull);
        expect(deepLink!.path, equals(DeepLinkPath.recurring));
      },
    );

    test(
      'recurringDetailDeepLink_flow parses recurring detail deep link correctly',
      () async {
        final uri = Uri.parse('expenso://recurring/recurring_789');

        await deepLinkService.handleDeepLink(uri);

        final deepLink = await deepLinkService.onDeepLinkReceived.first;

        expect(deepLink, isNotNull);
        expect(deepLink!.path, equals(DeepLinkPath.recurringDetail));
        expect(deepLink.id, equals('recurring_789'));
      },
    );

    test(
      'notificationsDeepLink_flow parses notifications deep link correctly',
      () async {
        final uri = Uri.parse('expenso://notifications');

        await deepLinkService.handleDeepLink(uri);

        final deepLink = await deepLinkService.onDeepLinkReceived.first;

        expect(deepLink, isNotNull);
        expect(deepLink!.path, equals(DeepLinkPath.notifications));
      },
    );

    test('unknownDeepLink_flow parses unknown path correctly', () async {
      final uri = Uri.parse('expenso://unknown/path');

      await deepLinkService.handleDeepLink(uri);

      final deepLink = await deepLinkService.onDeepLinkReceived.first;

      expect(deepLink, isNotNull);
      expect(deepLink!.path, equals(DeepLinkPath.unknown));
    });

    test('emptyDeepLink_flow parses empty path correctly', () async {
      final uri = Uri.parse('expenso://');

      await deepLinkService.handleDeepLink(uri);

      final deepLink = await deepLinkService.onDeepLinkReceived.first;

      expect(deepLink, isNotNull);
      expect(deepLink!.path, equals(DeepLinkPath.unknown));
    });

    test('deepLinkWithQueryParams_flow preserves query parameters', () async {
      final uri = Uri.parse(
        'expenso://expenses/exp_123?from=dashboard&tab=monthly',
      );

      await deepLinkService.handleDeepLink(uri);

      final deepLink = await deepLinkService.onDeepLinkReceived.first;

      expect(deepLink, isNotNull);
      expect(deepLink!.path, equals(DeepLinkPath.expenseDetail));
      expect(deepLink.id, equals('exp_123'));
      expect(deepLink.queryParams['from'], equals('dashboard'));
      expect(deepLink.queryParams['tab'], equals('monthly'));
    });
  });

  group('DeepLink Data Class Tests', () {
    test('DeepLink equality works correctly', () {
      const deepLink1 = DeepLink(path: DeepLinkPath.budgets);
      const deepLink2 = DeepLink(path: DeepLinkPath.budgets);
      const deepLink3 = DeepLink(path: DeepLinkPath.expenses);

      expect(deepLink1, equals(deepLink2));
      expect(deepLink1, isNot(equals(deepLink3)));
    });

    test('DeepLink with id stores correctly', () {
      const deepLink = DeepLink(
        path: DeepLinkPath.budgetDetail,
        id: 'test_id',
        queryParams: {'key': 'value'},
      );

      expect(deepLink.path, equals(DeepLinkPath.budgetDetail));
      expect(deepLink.id, equals('test_id'));
      expect(deepLink.queryParams['key'], equals('value'));
    });
  });
}
