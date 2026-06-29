class RecordsRoutes {
  static const String root = '/';
  static const String newRecord = '/records/new';
  static const String editRecord = '/records/:id/edit';

  static String editRecordPath(String id) => '/records/$id/edit';
}
