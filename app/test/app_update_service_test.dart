import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/update/app_update_service.dart';

void main() {
  group('AppUpdateService Tests', () {
    test('isNewerVersion accurately compares semver strings', () {
      expect(AppUpdateService.isNewerVersion('1.0.1', '1.0.0'), isTrue);
      expect(AppUpdateService.isNewerVersion('1.1.0', '1.0.9'), isTrue);
      expect(AppUpdateService.isNewerVersion('2.0.0', '1.9.9'), isTrue);
      expect(AppUpdateService.isNewerVersion('v1.0.1', '1.0.0'), isTrue);
      expect(AppUpdateService.isNewerVersion('v1.0.1', 'v1.0.0'), isTrue);
      expect(AppUpdateService.isNewerVersion('1.0.0.1', '1.0.0'), isTrue);

      expect(AppUpdateService.isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(AppUpdateService.isNewerVersion('1.0.0', '1.0.1'), isFalse);
      expect(AppUpdateService.isNewerVersion('0.9.9', '1.0.0'), isFalse);
      expect(AppUpdateService.isNewerVersion('invalid', '1.0.0'), isFalse);
    });

    test('checkForUpdate safely returns null in test environment without client', () async {
      final update = await AppUpdateService.checkForUpdate();
      expect(update, isNull);
    });

    test('currentVersion matches the pubspec version', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final version = RegExp(r'^version:\s*([^\s+]+)', multiLine: true)
          .firstMatch(pubspec)
          ?.group(1);

      expect(version, isNotNull);
      expect(AppUpdateService.currentVersion, version);
    });
  });
}
