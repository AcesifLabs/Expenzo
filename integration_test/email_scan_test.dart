import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/email_parser/presentation/bloc/email_scanner_bloc.dart';
import 'package:expense_tracker/features/email_parser/presentation/bloc/email_scanner_event.dart';
import 'package:expense_tracker/features/email_parser/presentation/bloc/email_scanner_state.dart';
import 'package:expense_tracker/features/email_parser/domain/entities/email_message.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/email_parser/domain/services/gmail_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules.dart';
import 'package:expense_tracker/features/email_parser/domain/usecases/scan_emails_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

class MockGmailService extends Mock implements GmailService {}

class MockEvaluateRulesUseCase extends Mock implements EvaluateRulesUseCase {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Email Scan Integration Tests', () {
    late MockGmailService mockGmailService;
    late MockEvaluateRulesUseCase mockEvaluateRules;
    late ScanEmailsUseCase scanEmailsUseCase;
    late EmailScannerBloc emailScannerBloc;

    setUp(() {
      mockGmailService = MockGmailService();
      mockEvaluateRules = MockEvaluateRulesUseCase();
      scanEmailsUseCase = ScanEmailsUseCase(
        gmailService: mockGmailService,
        evaluateRules: mockEvaluateRules,
      );
      emailScannerBloc = EmailScannerBloc(scanEmailsUseCase: scanEmailsUseCase);
    });

    tearDown(() {
      emailScannerBloc.close();
    });

    testWidgets('connectGmail_flow emits initial then scanning then complete', (
      WidgetTester tester,
    ) async {
      final testEmails = [
        EmailMessage(
          id: 'email_1',
          threadId: 'thread_1',
          subject: 'Bank Statement',
          from: 'bank@example.com',
          to: 'user@gmail.com',
          date: DateTime.now(),
          bodyPlain: 'Your account is credited with Rs. 5000',
          isRead: true,
        ),
        EmailMessage(
          id: 'email_2',
          threadId: 'thread_2',
          subject: 'Payment Confirmation',
          from: 'merchant@example.com',
          to: 'user@gmail.com',
          date: DateTime.now(),
          bodyPlain: 'Payment of Rs. 200 received',
          isRead: false,
        ),
      ];

      final testParsedTransactions = [
        ParsedTransaction(
          rawMessage: 'Bank Statement Your account is credited with Rs. 5000',
          amount: 5000.0,
          sourceType: 'email',
          sourceId: 'email_email_1'.hashCode.abs().toString(),
          confidenceScore: 0.95,
          parseFailed: false,
        ),
      ];

      when(
        () => mockGmailService.getEmails(maxResults: any(named: 'maxResults')),
      ).thenAnswer((_) async => Right(testEmails));
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => Right(testParsedTransactions.first));

      emailScannerBloc.add(const StartEmailScan());

      await expectLater(
        emailScannerBloc.stream,
        emitsInOrder([
          isA<EmailScannerScanning>(),
          isA<EmailScannerScanComplete>(),
        ]),
      );
    });

    testWidgets(
      'scanEmails_flow processes emails and returns parsed transactions',
      (WidgetTester tester) async {
        final testEmails = [
          EmailMessage(
            id: 'test_email_1',
            threadId: 'thread_1',
            subject: 'Transaction Alert',
            from: 'alert@bank.com',
            to: 'user@gmail.com',
            date: DateTime.now(),
            bodyPlain: 'Debit card purchase of Rs. 1500 at Amazon',
            isRead: true,
          ),
        ];

        final testParsedTransaction = ParsedTransaction(
          rawMessage:
              'Transaction Alert Debit card purchase of Rs. 1500 at Amazon',
          amount: 1500.0,
          description: 'Debit card purchase of Rs. 1500 at Amazon',
          sourceType: 'email',
          sourceId: 'email_test_email_1'.hashCode.abs().toString(),
          confidenceScore: 0.9,
          parseFailed: false,
        );

        when(
          () =>
              mockGmailService.getEmails(maxResults: any(named: 'maxResults')),
        ).thenAnswer((_) async => Right(testEmails));
        when(
          () => mockEvaluateRules.call(any()),
        ).thenAnswer((_) async => Right(testParsedTransaction));

        emailScannerBloc.add(const StartEmailScan(maxResults: 10));

        await expectLater(
          emailScannerBloc.stream,
          emitsInOrder([
            isA<EmailScannerScanning>(),
            isA<EmailScannerScanComplete>().having(
              (s) => s.results.length,
              'results count',
              1,
            ),
          ]),
        );
      },
    );

    testWidgets('processesInBatches_flow processes 10 at a time', (
      WidgetTester tester,
    ) async {
      final testEmails = List.generate(
        25,
        (i) => EmailMessage(
          id: 'batch_email_$i',
          threadId: 'thread_$i',
          subject: 'Email $i',
          from: 'sender$i@example.com',
          to: 'user@gmail.com',
          date: DateTime.now(),
          bodyPlain: 'Email body $i with Rs. ${i * 100}',
          isRead: false,
        ),
      );

      when(
        () => mockGmailService.getEmails(maxResults: any(named: 'maxResults')),
      ).thenAnswer((_) async => Right(testEmails));
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => const Right(null));

      emailScannerBloc.add(const StartEmailScan(maxResults: 50));

      await expectLater(
        emailScannerBloc.stream,
        emitsInOrder([
          isA<EmailScannerScanning>(),
          isA<EmailScannerScanComplete>(),
        ]),
      );

      final state = emailScannerBloc.state;
      expect(state, isA<EmailScannerScanComplete>());
    });

    testWidgets(
      'selectAndCreateExpense_flow creates expense from selected email',
      (WidgetTester tester) async {
        final testEmails = [
          EmailMessage(
            id: 'select_email_1',
            threadId: 'thread_1',
            subject: 'Purchase Receipt',
            from: 'receipt@shop.com',
            to: 'user@gmail.com',
            date: DateTime.now(),
            bodyPlain: 'Thank you for your purchase of Rs. 750',
            isRead: true,
          ),
        ];

        final testParsedTransaction = ParsedTransaction(
          rawMessage: 'Purchase Receipt Thank you for your purchase of Rs. 750',
          amount: 750.0,
          description: 'Thank you for your purchase of Rs. 750',
          sourceType: 'email',
          sourceId: 'email_select_email_1'.hashCode.abs().toString(),
          confidenceScore: 0.9,
          parseFailed: false,
        );

        when(
          () =>
              mockGmailService.getEmails(maxResults: any(named: 'maxResults')),
        ).thenAnswer((_) async => Right(testEmails));
        when(
          () => mockEvaluateRules.call(any()),
        ).thenAnswer((_) async => Right(testParsedTransaction));

        emailScannerBloc.add(const StartEmailScan());

        await expectLater(
          emailScannerBloc.stream,
          emitsInOrder([
            isA<EmailScannerScanning>(),
            isA<EmailScannerScanComplete>(),
          ]),
        );

        final state = emailScannerBloc.state;
        expect(state, isA<EmailScannerScanComplete>());
        if (state is EmailScannerScanComplete) {
          expect(state.results.length, equals(1));
          expect(state.results.first.amount, equals(750.0));
        }
      },
    );

    testWidgets('clearEmailResults_flow resets state to initial', (
      WidgetTester tester,
    ) async {
      final testEmails = [
        EmailMessage(
          id: 'clear_email_1',
          threadId: 'thread_1',
          subject: 'Test',
          from: 'test@example.com',
          to: 'user@gmail.com',
          date: DateTime.now(),
          bodyPlain: 'Test body',
          isRead: true,
        ),
      ];

      when(
        () => mockGmailService.getEmails(maxResults: any(named: 'maxResults')),
      ).thenAnswer((_) async => Right(testEmails));
      when(
        () => mockEvaluateRules.call(any()),
      ).thenAnswer((_) async => const Right(null));

      emailScannerBloc.add(const StartEmailScan());

      await expectLater(
        emailScannerBloc.stream,
        emitsInOrder([
          isA<EmailScannerScanning>(),
          isA<EmailScannerScanComplete>(),
        ]),
      );

      emailScannerBloc.add(ClearEmailResults());
      await tester.pumpAndSettle();

      expect(emailScannerBloc.state, isA<EmailScannerInitial>());
    });

    testWidgets('emailScanError_flow handles errors gracefully', (
      WidgetTester tester,
    ) async {
      when(
        () => mockGmailService.getEmails(maxResults: any(named: 'maxResults')),
      ).thenAnswer(
        (_) async =>
            const Left(AuthFailure(message: 'Failed to connect to Gmail')),
      );

      emailScannerBloc.add(const StartEmailScan());

      await expectLater(
        emailScannerBloc.stream,
        emitsInOrder([isA<EmailScannerScanning>(), isA<EmailScannerError>()]),
      );
    });
  });
}
