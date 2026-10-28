import 'package:equatable/equatable.dart';

class ExportFile extends Equatable {
  final String path;

  final String mimeType;

  static const csvMimeType = 'text/csv';
  static const zipMimeType = 'application/zip';

  @override
  List<Object?> get props => [path, mimeType];

  const ExportFile({required this.path, required this.mimeType});
}
