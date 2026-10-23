import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:expense_tracker/features/support/domain/app_version.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

void main() {
  test('reads the version and build of the installed package', () async {
    PackageInfo.setMockInitialValues(
      appName: 'Expenzo',
      packageName: 'com.acesiflabs.expenzo',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );

    expect(
      await loadAppVersion(),
      const AppVersion(version: '1.2.3', build: '45'),
    );
  });

  test('a failing platform call gives the unknown version', () async {
    final version = await loadAppVersion(load: () => Future.error('no'));

    expect(version, AppVersion.unknown);
    expect(version.isUnknown, isTrue);
  });

  test('the version line reads "Version 1.2.3 (45)"', () {
    LocaleSettings.setLocaleSync(AppLocale.en);

    expect(
      t.support.about.version(version: '1.2.3', build: '45'),
      'Version 1.2.3 (45)',
    );
  });
}
