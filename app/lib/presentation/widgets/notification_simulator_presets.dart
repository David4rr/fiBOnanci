import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

const Map<String, String> kNotificationSimulatorPresets = {
  'BCA QRIS': 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil.',
  'blu QRIS': 'Pembayaran QRIS sebesar Rp 45.000 di Kopi Kenangan telah berhasil.',
  'blu Transfer In': 'Kamu menerima transfer sebesar Rp 250.000 dari SITI NURHALIZA.',
  'Livin Mandiri QR': "Transaksi Livin' QR sebesar IDR 75.000 di HokBen Paskal berhasil.",
  'Bank Jago Jajan': 'Kamu telah membayar Rp 68.000 ke FamilyMart menggunakan Kantong Jajan.',
  'SeaBank Transfer': 'Berhasil transfer Rp 150.000 ke DANA Siti Aminah.',
  'OVO Cash': 'Berhasil bayar Rp 52.000 di Janji Jiwa.',
};

class NotificationSimulatorPresetsChips extends StatelessWidget {
  final void Function(String key, String body, String package) onSelectPreset;

  const NotificationSimulatorPresetsChips({
    super.key,
    required this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kNotificationSimulatorPresets.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: AppColors.canvasInputSearch,
              side: const BorderSide(color: AppColors.canvasBorder),
              label: Text(entry.key, style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
              onPressed: () {
                String pkg = 'com.bca';
                if (entry.key.contains('BCA QRIS')) pkg = 'com.bca';
                if (entry.key.contains('blu')) pkg = 'com.bcadigital.blu';
                if (entry.key.contains('Mandiri')) pkg = 'com.bankmandiri.livin';
                if (entry.key.contains('Jago')) pkg = 'com.bankjago.app';
                if (entry.key.contains('SeaBank')) pkg = 'com.seabank.id';
                if (entry.key.contains('OVO')) pkg = 'ovo.id';
                onSelectPreset(entry.key, entry.value, pkg);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
