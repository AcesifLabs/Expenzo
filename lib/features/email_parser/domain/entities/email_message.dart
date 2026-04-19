import 'package:equatable/equatable.dart';

class EmailMessage extends Equatable {
  final String id;
  final String threadId;
  final String? subject;
  final String from;
  final String to;
  final DateTime date;
  final String? bodyPlain;
  final String? bodyHtml;
  final bool isRead;

  const EmailMessage({
    required this.id,
    required this.threadId,
    this.subject,
    required this.from,
    required this.to,
    required this.date,
    this.bodyPlain,
    this.bodyHtml,
    required this.isRead,
  });

  String get snippet {
    final body = bodyPlain ?? bodyHtml ?? '';
    if (body.length <= 100) return body;
    return '${body.substring(0, 100)}...';
  }

  @override
  List<Object?> get props => [
    id,
    threadId,
    subject,
    from,
    to,
    date,
    bodyPlain,
    bodyHtml,
    isRead,
  ];
}
