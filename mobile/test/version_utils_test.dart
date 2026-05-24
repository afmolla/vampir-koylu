import 'package:flutter_test/flutter_test.dart';
import 'package:vampir_koylu/core/version_utils.dart';

void main() {
  test('resolveUpdateApkUrl prefers versioned server URL over latest', () {
    final url = resolveUpdateApkUrl({
      'apkPublishVersion': '0.2.31',
      'latestVersion': '0.2.31',
      'updateUrlAndroid':
          'https://github.com/afmolla/vampir-koylu/releases/download/v0.2.31/app-release.apk',
      'updateUrlLatest':
          'https://github.com/afmolla/vampir-koylu/releases/latest/download/app-release.apk',
    });
    expect(url, contains('/v0.2.31/'));
    expect(url, isNot(contains('/latest/')));
  });

  test('isVersionOlder compares semver', () {
    expect(isVersionOlder('0.2.25', '0.2.30'), isTrue);
    expect(isVersionOlder('0.2.30', '0.2.25'), isFalse);
  });
}
