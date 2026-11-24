import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/update/app_update_downloader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DownloadProgressInfo Tests', () {
    test('computes percentages and formatting correctly', () {
      const info = DownloadProgressInfo(
        status: 'running',
        bytesDownloaded: 15 * 1024 * 1024,
        totalBytes: 30 * 1024 * 1024,
        progress: 0.50,
      );

      expect(info.isCompleted, isFalse);
      expect(info.isRunning, isTrue);
      expect(info.isFailed, isFalse);
      expect(info.formattedDownloaded, '15.0 MB');
      expect(info.formattedTotal, '30.0 MB');
      expect(info.percentageText, '50%');
    });

    test('isCompleted is true when status is successful or progress is 1.0', () {
      const infoSuccess = DownloadProgressInfo(
        status: 'successful',
        bytesDownloaded: 2000,
        totalBytes: 2000,
        progress: 1.0,
      );
      expect(infoSuccess.isCompleted, isTrue);

      const infoFailed = DownloadProgressInfo(
        status: 'failed',
        bytesDownloaded: 500,
        totalBytes: 2000,
        progress: 0.25,
      );
      expect(infoFailed.isFailed, isTrue);
      expect(infoFailed.isCompleted, isFalse);
    });

    test('parses fromMap gracefully with null or missing fields', () {
      final info = DownloadProgressInfo.fromMap({
        'status': 'running',
        'bytesDownloaded': 1048576,
        'totalBytes': 2097152,
        'progress': 0.5,
      });

      expect(info.status, 'running');
      expect(info.bytesDownloaded, 1048576);
      expect(info.totalBytes, 2097152);
      expect(info.progress, 0.5);

      final emptyInfo = DownloadProgressInfo.fromMap({});
      expect(emptyInfo.status, 'unknown');
      expect(emptyInfo.bytesDownloaded, 0);
      expect(emptyInfo.totalBytes, -1);
      expect(emptyInfo.progress, 0.0);
    });
  });
}
