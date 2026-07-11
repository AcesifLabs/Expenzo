import 'package:equatable/equatable.dart';

import 'sms_scan_result_item.dart';

class SmsScanPage extends Equatable {
  final List<SmsScanResultItem> results;
  final int nextOffset;
  final bool hasReachedMax;

  @override
  List<Object?> get props => [results, nextOffset, hasReachedMax];

  const SmsScanPage({
    required this.results,
    required this.nextOffset,
    required this.hasReachedMax,
  });
}
