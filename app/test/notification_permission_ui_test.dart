import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/native_bridge/notification_bridge.dart';
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

    testWidgets('tapping Unduh & Pasang Pembaruan triggers downloadApk and shows snackbar', (tester) async {
      String? invokedMethod;
      Map<dynamic, dynamic>? invokedArguments;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async {
          invokedMethod = methodCall.method;
          invokedArguments = methodCall.arguments as Map<dynamic, dynamic>?;
          if (methodCall.method == 'downloadApk') {
            return true;
          }
          return null;
        },
      );

      const info = AppUpdateInfo(
        currentVersion: '1.0.0',
        latestVersion: '1.0.1',
        hasUpdate: true,
        releaseNotes: 'Performance improvements',
        apkUrl: 'https://github.com/David4rr/fiBOnanci/releases/download/v1.0.1/fiBOnanci-arm64-v8a.apk',
        htmlUrl: 'https://github.com/David4rr/fiBOnanci/releases/tag/v1.0.1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () => AppUpdateModal.show(ctx, info),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unduh & Pasang Pembaruan'));
      await tester.pumpAndSettle();

      expect(invokedMethod, equals('downloadApk'));
      expect(invokedArguments?['fileName'], equals('fiBOnanci-v1.0.1.apk'));
      expect(find.textContaining('Mengunduh pembaruan v1.0.1'), findsOneWidget);
    });

    testWidgets('NotificationBridge.isPermissionGranted returns a valid boolean without throwing', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'isPermissionGranted') {
            return false;
          }
          return null;
        },
      );

      final granted = await NotificationBridge.isPermissionGranted();
      expect(granted, isFalse);
    });
  });
}
