import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/email_message.dart';

abstract class GmailApiDatasource {
  Future<List<EmailMessage>> listMessages({
    int maxResults = 50,
    String? pageToken,
  });
  Future<EmailMessage> getMessage(String messageId);
}

class GmailApiDatasourceImpl implements GmailApiDatasource {
  final GoogleSignIn googleSignIn;
  final http.Client httpClient;

  GmailApiDatasourceImpl({
    required this.googleSignIn,
    required this.httpClient,
  });

  static const String _gmailApiBase = 'https://gmail.googleapis.com/gmail/v1';

  Future<Map<String, String>> _getAuthHeaders() async {
    final account = googleSignIn.currentUser;
    if (account == null) {
      throw Exception('Not signed in to Google');
    }
    return await account.authHeaders;
  }

  @override
  Future<List<EmailMessage>> listMessages({
    int maxResults = 50,
    String? pageToken,
  }) async {
    final headers = await _getAuthHeaders();

    var url = '$_gmailApiBase/users/me/messages?maxResults=$maxResults';
    if (pageToken != null) {
      url += '&pageToken=$pageToken';
    }

    final response = await httpClient.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 429) {
      await Future.delayed(const Duration(seconds: 1));
      return listMessages(maxResults: maxResults, pageToken: pageToken);
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to list messages: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final messages = data['messages'] as List<dynamic>? ?? [];

    final List<EmailMessage> emails = [];
    for (final msg in messages) {
      try {
        final email = await getMessage(msg['id'] as String);
        emails.add(email);
      } catch (e) {
        // Skip messages that fail to load
      }
    }

    return emails;
  }

  @override
  Future<EmailMessage> getMessage(String messageId) async {
    final headers = await _getAuthHeaders();

    final response = await httpClient.get(
      Uri.parse('$_gmailApiBase/users/me/messages/$messageId'),
      headers: headers,
    );

    if (response.statusCode == 429) {
      await Future.delayed(const Duration(seconds: 1));
      return getMessage(messageId);
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to get message: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    return _parseMessage(data);
  }

  EmailMessage _parseMessage(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>;
    final headers = payload['headers'] as List<dynamic>? ?? [];

    String getHeader(String name) {
      for (final h in headers) {
        final header = h as Map<String, dynamic>;
        if (header['name']?.toLowerCase() == name.toLowerCase()) {
          return header['value'] as String? ?? '';
        }
      }
      return '';
    }

    final internalDate = data['internalDate'] as String? ?? '0';
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(internalDate));

    String? bodyPlain;
    String? bodyHtml;

    bodyPlain = _extractBody(payload, 'text/plain');
    bodyHtml = _extractBody(payload, 'text/html');

    return EmailMessage(
      id: data['id'] as String? ?? '',
      threadId: data['threadId'] as String? ?? '',
      subject: getHeader('Subject'),
      from: getHeader('From'),
      to: getHeader('To'),
      date: date,
      bodyPlain: bodyPlain,
      bodyHtml: bodyHtml,
      isRead: data['labelIds'] != null
          ? !(data['labelIds'] as List).contains('UNREAD')
          : true,
    );
  }

  String? _extractBody(Map<String, dynamic> payload, String mimeType) {
    if (payload['parts'] == null) {
      if (payload['body'] != null) {
        final body = payload['body'] as Map<String, dynamic>;
        if (body['data'] != null) {
          final data = body['data'] as String;
          return utf8.decode(
            base64.decode(data.replaceAll('-', '+').replaceAll('_', '/')),
          );
        }
      }
      return null;
    }

    final parts = payload['parts'] as List<dynamic>;
    for (final part in parts) {
      final p = part as Map<String, dynamic>;
      if (p['mimeType'] == mimeType) {
        if (p['body'] != null) {
          final body = p['body'] as Map<String, dynamic>;
          if (body['data'] != null) {
            final data = body['data'] as String;
            return utf8.decode(
              base64.decode(data.replaceAll('-', '+').replaceAll('_', '/')),
            );
          }
        }
      }
      if (p['parts'] != null) {
        final nestedBody = _extractBody(p, mimeType);
        if (nestedBody != null) return nestedBody;
      }
    }
    return null;
  }
}
