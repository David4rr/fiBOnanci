import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/update/app_update_service.dart';
import 'package:fibonanci_app/presentation/modals/app_update_modal.dart';
import 'package:fibonanci_app/presentation/modals/notification_permission_modal.dart';
import 'package:fibonanci_app/presentation/widgets/notification_permission_banner.dart';

void main() {
  group('Notification & Update UI Tests', () {
    testWidgets('renders NotificationPermissionModal correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationPermissionModal(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Akses Notifikasi Bank'), findsOneWidget);
      expect(find.text('Pencatatan Otomatis 100% Offline'), findsOneWidget);
      expect(find.text('Buka Pengaturan Izin'), findsOneWidget);
      expect(find.text('Nanti Saja'), findsOneWidget);
      expect(find.textContaining('Tips Android 13+'), findsOneWidget);
    });

    testWidgets('renders NotificationPermissionBanner and dismisses on close tap', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationPermissionBanner(
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Akses Notifikasi Belum Aktif'), findsOneWidget);
      expect(find.text('Aktifkan'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('Akses Notifikasi Belum Aktif'), findsNothing);
    });

    testWidgets('renders AppUpdateModal with version information and changelog', (tester) async {
      const info = AppUpdateInfo(
        currentVersion: '1.0.0',
        latestVersion: '1.0.1',
        hasUpdate: true,
        releaseNotes: 'Fixed notification bugs and improved performance.',
        apkUrl: 'https://example.com/fibonanci.apk',
        htmlUrl: 'https://example.com/release',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppUpdateModal(updateInfo: info),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pembaruan Tersedia'), findsOneWidget);
      expect(find.text('Versi v1.0.1 siap diunduh'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('v1.0.1'), findsOneWidget);
      expect(find.text('Fixed notification bugs and improved performance.'), findsOneWidget);
      expect(find.text('Unduh & Pasang Pembaruan'), findsOneWidget);
    });
  });
}
