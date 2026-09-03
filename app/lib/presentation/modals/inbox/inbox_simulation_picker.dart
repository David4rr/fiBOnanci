import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

final List<Map<String, dynamic>> kInboxSimulationPresets = [
  {
    'bank': 'BCA mobile',
    'desc': 'QRIS Kopi Kenangan Rp 35.000 (Pengeluaran)',
    'color': AppColors.neoCoral,
    'payload': {
      'package': 'com.bca',
      'title': 'BCA mobile',
      'text': 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil. Sisa saldo Rp 1.450.000',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  },
  {
    'bank': 'SeaBank',
    'desc': 'Transfer Masuk Rp 500.000 (Pemasukan)',
    'color': AppColors.neoMint,
    'payload': {
      'package': 'com.seabank.mobile',
      'title': 'SeaBank',
      'text': 'Transfer masuk sebesar Rp 500.000 dari BUDI SANTOSO berhasil.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  },
  {
    'bank': 'ShopeePay',
    'desc': 'Fore Coffee Rp 42.000 (Pengeluaran)',
    'color': AppColors.neoCoral,
    'payload': {
      'package': 'com.shopee.id',
      'title': 'ShopeePay',
      'text': 'Pembayaran Rp 42.000 ke Fore Coffee berhasil.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  },
  {
    'bank': 'Livin\' by Mandiri',
    'desc': 'QRIS Superindo Rp 125.000 (Pengeluaran)',
    'color': AppColors.neoCoral,
    'payload': {
      'package': 'com.bankmandiri.mandirionline',
      'title': 'Livin\' by Mandiri',
      'text': 'Pembayaran QRIS sebesar Rp 125.000 di Superindo berhasil.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  },
  {
    'bank': 'blu by BCA',
    'desc': 'Transfer Tokopedia Rp 150.000 (Pengeluaran)',
    'color': AppColors.neoCoral,
    'payload': {
      'package': 'com.bcadigital.blu',
      'title': 'blu by BCA Digital',
      'text': 'Transfer keluar Rp 150.000 ke Tokopedia berhasil.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  },
  {
    'bank': 'GoPay',
    'desc': 'Merchant Alfamart Rp 22.000 (Pengeluaran)',
    'color': AppColors.neoCoral,
    'payload': {
      'package': 'com.gojek.app',
      'title': 'GoPay',
      'text': 'Pembayaran sebesar Rp 22.000 di Alfamart berhasil.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  },
  {
    'bank': 'Bank Jago',
    'desc': 'Mixue Ice Cream Rp 65.000 (Pengeluaran)',
    'color': AppColors.neoCoral,
    'payload': {
      'package': 'com.jago.app',
      'title': 'Bank Jago',
      'text': 'Kamu berhasil membayar Rp 65.000 di Mixue.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  },
];

class InboxSimulationPicker {
  static void show(BuildContext context, ValueChanged<Map<String, dynamic>> onSelectPayload) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C0D11),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                    border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.neoChartreuse, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Pilih Skenario Notifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: AppColors.textWhite)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: kInboxSimulationPresets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final p = kInboxSimulationPresets[i];
                  final Color c = p['color'] as Color;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        final payload = Map<String, dynamic>.from(p['payload'] as Map<String, dynamic>);
                        payload['timestamp'] = DateTime.now().millisecondsSinceEpoch;
                        onSelectPayload(payload);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13151D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.15)),
                              child: Icon(Icons.notifications_active_rounded, color: c, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['bank'] as String, style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(p['desc'] as String, style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
