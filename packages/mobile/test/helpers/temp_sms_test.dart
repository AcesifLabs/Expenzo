import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

void main() {
  final query = SmsQuery();
  query.querySms(
    kinds: [SmsQueryKind.inbox],
    address: "a",
    count: 10,
    start: 0,
  );
}
