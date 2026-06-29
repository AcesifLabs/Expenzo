class RecordFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;
  final String? recordType;
  final int? limit;
  final int? offset;

  const RecordFilter({
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.recordType,
    this.limit,
    this.offset,
  });
}
