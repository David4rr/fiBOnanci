import 'notification_review_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/notification_parser/notification_parser.dart';
import '../../core/notification_parser/parsed_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NotificationSimulatorModal extends StatefulWidget {
  const NotificationSimulatorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NotificationSimulatorModal(),
    );
  }

  @override
  State<NotificationSimulatorModal> createState() => _NotificationSimulatorModalState();
}

class _NotificationSimulatorModalState extends State<NotificationSimulatorModal> {
  String _selectedPackage = 'com.bca';
  final _bodyController = TextEditingController(
    text: 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil.',
  );

  ParsedNotificationResult? _parsedResult;

  final Map<String, String> _presets = {
    'BCA QRIS': 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil.',
    'blu QRIS': 'Pembayaran QRIS sebesar Rp 45.000 di Kopi Kenangan telah berhasil.',
    'blu Transfer In': 'Kamu menerima transfer sebesar Rp 250.000 dari SITI NURHALIZA.',
    'Livin Mandiri QR': "Transaksi Livin' QR sebesar IDR 75.000 di HokBen Paskal berhasil.",
    'Bank Jago Jajan': 'Kamu telah membayar Rp 68.000 ke FamilyMart menggunakan Kantong Jajan.',
    'SeaBank Transfer': 'Berhasil transfer Rp 150.000 ke DANA Siti Aminah.',
    'OVO Cash': 'Berhasil bayar Rp 52.000 di Janji Jiwa.',
  };

  @override
  void initState() {
    super.initState();
    _triggerParse();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _triggerParse() {
    final result = NotificationParser.parse(
      packageName: _selectedPackage,
      title: 'Notifikasi Bank',
      body: _bodyController.text.trim(),
    );
    setState(() => _parsedResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: AppColors.neoChartreuse, size: 22),
                    const SizedBox(width: 8),
                    Text('Simulator Notifikasi Bank', style: AppTypography.sectionTitle),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Uji coba parsing notifikasi perbankan Indonesia langsung di memori HP.',
              style: AppTypography.listSubtitle,
            ),
            const SizedBox(height: 16),

            // Presets chips
            Text('PRESET NOTIFIKASI NYATA', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presets.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.canvasInputSearch,
                      side: const BorderSide(color: AppColors.canvasBorder),
                      label: Text(entry.key, style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
                      onPressed: () {
                        setState(() {
                          _bodyController.text = entry.value;
                          if (entry.key.contains('BCA QRIS')) _selectedPackage = 'com.bca';
                          if (entry.key.contains('blu')) _selectedPackage = 'com.bcadigital.blu';
                          if (entry.key.contains('Mandiri')) _selectedPackage = 'com.bankmandiri.livin';
                          if (entry.key.contains('Jago')) _selectedPackage = 'com.bankjago.app';
                          if (entry.key.contains('SeaBank')) _selectedPackage = 'com.seabank.id';
                          if (entry.key.contains('OVO')) _selectedPackage = 'ovo.id';
                        });
                        _triggerParse();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Body text editor
            Text('BODY TEKS NOTIFIKASI', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              style: AppTypography.listTitle,
              onChanged: (_) => _triggerParse(),
              decoration: InputDecoration(
                hintText: 'Tempel teks notifikasi di sini...',
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 18),

            // Live Parser Output Card
            Text('HASIL PARSING REALTIME (ON-DEVICE)', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _parsedResult != null ? AppColors.neoMint.withValues(alpha: 0.08) : AppColors.canvasInputSearch,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _parsedResult != null ? AppColors.neoMint.withValues(alpha: 0.4) : AppColors.canvasBorder,
                ),
              ),
              child: _parsedResult != null
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nominal Terdeteksi:', style: AppTypography.listSubtitle),
                            Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_parsedResult!.amount),
                              style: AppTypography.listAmount.copyWith(color: AppColors.neoMint),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Merchant / Rekanan:', style: AppTypography.listSubtitle),
                            Text(_parsedResult!.counterparty, style: AppTypography.listTitle),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tipe Arah:', style: AppTypography.listSubtitle),
                            Text(_parsedResult!.type.toUpperCase(), style: AppTypography.badgeLabel.copyWith(color: AppColors.neoCoral)),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Pola teks tidak cocok atau diblokir filter keamanan (OTP/Promo)',
                          style: AppTypography.listSubtitle.copyWith(color: AppColors.statusDeficit),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Ingest to SQLite button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neoChartreuse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check_circle_outline, color: AppColors.textDarkPrimary),
                label: Text(
                  'Review & Konfirmasi Tujuan',
                  style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                ),
                onPressed: _parsedResult == null
                    ? null
                    : () async {
                        final confirmed = await NotificationReviewModal.show(
                          context,
                          parsed: _parsedResult!,
                          rawPackage: _selectedPackage,
                        );
                        if (confirmed == true && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.neoMint,
                              content: Text(
                                'Transaksi berhasil dikonfirmasi dan dicatat!',
                                style: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
