import 'package:flutter/material.dart';

import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notifications/local_notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common/modal_grab_handle.dart';
import '../widgets/common/modal_sheet_scaffold.dart';
import '../widgets/common/primary_action_button.dart';

class NotificationPermissionModal extends StatelessWidget {
  const NotificationPermissionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationPermissionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: ModalGrabHandle()),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neoMint.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.neoMint.withAlpha(60)),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.neoMint, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Akses Notifikasi Bank', style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text(
                      'Pencatatan Otomatis 100% Offline',
                      style: TextStyle(color: AppColors.neoMint, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Deteksi Transaksi Otomatis',
            subtitle: 'Membaca notifikasi dari bank & e-wallet resmi untuk mencatat pengeluaran/pemasukan tanpa login akun bank.',
          ),
          const SizedBox(height: 10),
          _buildInfoTile(
            icon: Icons.security_rounded,
            title: 'Privasi & Keamanan Terjaga',
            subtitle: 'Data diproses lokal di perangkat Anda. OTP, PIN, dan pesan sensitif otomatis dibuang demi keamanan.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvasBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.neoChartreuse, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tips Android 13+: Jika tombol izin abu-abu di setelan, buka Info Aplikasi fiBOnanci > titik tiga (⋮) pojok kanan atas > pilih "Izinkan setelan yang dibatasi".',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryActionButton(
            text: 'Buka Pengaturan Izin',
            icon: Icons.settings_outlined,
            onPressed: () async {
              Navigator.pop(context);
              await LocalNotificationService.instance.requestPermissions();
              await NotificationBridge.openPermissionSettings();
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti Saja', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.canvasBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textWhite, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
