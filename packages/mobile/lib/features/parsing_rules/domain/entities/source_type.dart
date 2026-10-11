import 'package:expense_tracker/i18n/strings.g.dart';

/// Source type filter for parsing rules.
enum SourceType {
  sms,
  email,
  both;

  String get displayName => switch (this) {
    SourceType.sms => t.enums.source.sms,
    SourceType.email => t.enums.source.email,
    SourceType.both => t.enums.source.both,
  };
}
