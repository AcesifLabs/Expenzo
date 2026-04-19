import 'package:dartz/dartz.dart';
import 'package:html/parser.dart' as html_parser;
import '../../../../core/error/failures.dart';
import '../../domain/entities/email_message.dart';
import '../../domain/services/gmail_service.dart';
import '../datasources/gmail_api_datasource.dart';

class GmailServiceImpl implements GmailService {
  final GmailApiDatasource datasource;

  GmailServiceImpl({required this.datasource});

  @override
  Future<Either<Failure, List<EmailMessage>>> getEmails({
    int maxResults = 50,
    String? pageToken,
  }) async {
    try {
      final messages = await datasource.listMessages(
        maxResults: maxResults,
        pageToken: pageToken,
      );
      return Right(messages);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmailMessage>> getEmailById(String id) async {
    try {
      final message = await datasource.getMessage(id);
      return Right(_parseEmailBody(message));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  EmailMessage _parseEmailBody(EmailMessage email) {
    String? plainBody = email.bodyPlain;
    String? htmlBody = email.bodyHtml;

    if (plainBody == null && htmlBody != null) {
      final document = html_parser.parse(htmlBody);
      plainBody = document.body?.text ?? htmlBody;
    }

    return EmailMessage(
      id: email.id,
      threadId: email.threadId,
      subject: email.subject,
      from: email.from,
      to: email.to,
      date: email.date,
      bodyPlain: plainBody,
      bodyHtml: htmlBody,
      isRead: email.isRead,
    );
  }
}
