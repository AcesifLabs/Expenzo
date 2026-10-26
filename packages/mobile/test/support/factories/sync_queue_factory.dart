Map<String, dynamic> makeSyncChange({
  String? table,
  String? action,
  String? id,
  Map<String, dynamic>? data,
  String? updatedAt,
}) {
  return {
    'table': table ?? 'records',
    'action': action ?? 'insert',
    'id': id ?? 'rec-00000001',
    'data': data,
    'updatedAt': updatedAt ?? '2024-06-15T10:30:00.000Z',
  };
}
