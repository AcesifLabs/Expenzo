import 'package:equatable/equatable.dart';

/// A written export, ready to share.
class ExportFile extends Equatable {
  final String path;

  /// [csvMimeType] for a single file, [zipMimeType] for several.
  final String mimeType;

  static const csvMimeType = 'text/csv';
  static const zipMimeType = 'application/zip';

  @override
  List<Object?> get props => [path, mimeType];

  const ExportFile({required this.path, required this.mimeType});
}
