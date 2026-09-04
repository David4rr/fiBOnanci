import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/notification_parser/notification_parser.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';
import 'notification_review_modal.dart';
import 'notification_simulator_presets.dart';

export 'notification_simulator_presets.dart';

class NotificationSimulatorModal extends StatefulWidget {
  const NotificationSimulatorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const NotificationSimulatorModal(),
    );
  }

  @override
  State<NotificationSimulatorModal> createState() => _NotificationSimulatorModalState();
}

class _NotificationSimulatorModalState extends State<NotificationSimulatorModal> {
  String _selectedPackage = 'com.bca';
  final _bodyController = TextEditingController(text: 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil.');
  ParsedNotificationResult? _parsedResult;

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
            const ModalGrabHandle(padding: EdgeInsets.only(bottom: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.flash_on, color: AppColors.neoChartreuse, size: 22),
                  const SizedBox(width: 8),
                  Text('Simulator Notifikasi Bank', style: AppTypography.sectionTitle),
                ]),
                IconButton(icon: const Icon(Icons.close, color: AppColors.textMuted), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Text('PRESET NOTIFIKASI NYATA', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            NotificationSimulatorPresetsChips(
              onSelectPreset: (key, body, pkg) {
                setState(() {
                  _bodyController.text = body;
                  _selectedPackage = pkg;
                });
                _triggerParse();
              },
            ),
            const SizedBox(height: 16),
            Text('BODY TEKS NOTIFIKASI', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            AppTextField(
              controller: _bodyController,
              hintText: 'Tempel teks notifikasi di sini...',
              maxLines: 3,
              onChanged: (_) => _triggerParse(),
            ),
            const SizedBox(height: 18),
            Text('HASIL PARSING REALTIME (ON-DEVICE)', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.canvasInputSearch,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _parsedResult != null
                      ? (_parsedResult!.type == 'income' ? AppColors.neoMint : AppColors.neoCoral).withValues(alpha: 0.4)
                      : AppColors.statusDeficit.withValues(alpha: 0.4),
                ),
              ),
              child: _parsedResult != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (_parsedResult!.type == 'income' ? AppColors.neoMint : AppColors.neoCoral).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _parsedResult!.type.toUpperCase(),
                                style: TextStyle(
                                  color: _parsedResult!.type == 'income' ? AppColors.neoMint : AppColors.neoCoral,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_parsedResult!.amount),
                              style: AppTypography.cardMetricLabel.copyWith(
                                color: _parsedResult!.type == 'income' ? AppColors.neoMint : AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Pihak Terkait: ${_parsedResult!.counterparty}', style: AppTypography.listSubtitle),
                        const SizedBox(height: 4),
                        Text('Fingerprint: ${_parsedResult!.externalRef ?? '-'}', style: AppTypography.badgeLabel.copyWith(color: AppColors.textSubtle)),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neoChartreuse,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              NotificationReviewModal.show(context, parsed: _parsedResult!, rawPackage: _selectedPackage);
                            },
                            child: const Text('Buka Modal Review Nyata', style: TextStyle(color: AppColors.canvasBg, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.statusDeficit, size: 20),
                            SizedBox(width: 8),
                            Text('Tidak Dikenali atau Diblokir', style: TextStyle(color: AppColors.statusDeficit, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Format regex belum cocok atau teks terdeteksi sebagai OTP/promo/iklan.', style: AppTypography.listSubtitle),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
