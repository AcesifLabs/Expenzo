import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/email_message.dart';

abstract class GmailService {
  Future<Either<Failure, List<EmailMessage>>> getEmails({
    int maxResults = 50,
    String? pageToken,
  });
  Future<Either<Failure, EmailMessage>> getEmailById(String id);
}
