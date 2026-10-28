import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:expense_tracker/core/logger/app_logger.dart';

class AppVersion extends Equatable {
  static const unknown = AppVersion(version: '', build: '');

  final String version;
  final String build;

  bool get isUnknown => version.isEmpty;

  @override
  List<Object?> get props => [version, build];

  const AppVersion({required this.version, required this.build});
}

typedef PackageInfoLoader = Future<PackageInfo> Function();

Future<AppVersion> loadAppVersion({
  PackageInfoLoader load = PackageInfo.fromPlatform,
}) async {
  try {
    final info = await load();

    return AppVersion(version: info.version, build: info.buildNumber);
  } catch (e, s) {
    appLogger.error('Reading the app version failed', e, s);

    return AppVersion.unknown;
  }
}
