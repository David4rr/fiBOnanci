import 'package:flutter/material.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/notification_review_modal.dart';
import 'budgeting_insights_modal.dart';

Widget buildCalcRow(String label, String val, Color color, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}

class WalletsListModal {
  static void show(BuildContext context, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Rincian Saldo Rekening', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              for (final w in wallets)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(int.parse(w.colorHex.replaceFirst('#', '0xFF'))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(w.name, style: AppTypography.listTitle),
                      const Spacer(),
                      Text('Rp ${w.balance.toStringAsFixed(0)}', style: AppTypography.listAmount),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class BillsListModal {
  static void show(BuildContext context, List<SubscriptionEntry> subscriptions) {
    BudgetingInsightsModal.show(context, subscriptions: subscriptions);
  }
}

class DailyPaceModal {
  static void show(BuildContext context, SafeToSpendMetrics metrics) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Alokasi Harian (Daily Pace)', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.canvasInputSearch,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    buildCalcRow(
                      'Sisa Hari Bulan Ini',
                      '${metrics.daysRemainingInMonth} Hari',
                      AppColors.textWhite,
                    ),
                    const Divider(color: AppColors.canvasBorder),
                    buildCalcRow(
                      'Batas Aman Belanja / Hari',
                      'Rp ${metrics.safeToSpendDaily.toStringAsFixed(0)}',
                      AppColors.neoCyan,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Menjaga belanja rata-rata harian Anda di bawah angka ini akan menjamin keuangan tetap surplus hingga akhir bulan.',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class ProfileModal {
  static void show(BuildContext context, {required int walletCount, required int txCount}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E212D),
                    ),
                    child: const Icon(Icons.person, color: AppColors.textWhite, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('David Arrozaqi', style: AppTypography.heroGreeting.copyWith(fontSize: 20)),
                      Text('Akun Lokal Offline-First', style: AppTypography.listSubtitle),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.canvasInputSearch,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    buildCalcRow('Total Rekening Terhubung', '$walletCount Akun', AppColors.textWhite),
                    const Divider(color: AppColors.canvasBorder),
                    buildCalcRow('Total Transaksi Tercatat', '$txCount Transaksi', AppColors.textWhite),
                    const Divider(color: AppColors.canvasBorder),
                    buildCalcRow('Status Database', 'SQLite Aktif (Offline)', AppColors.neoMint),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class PendingInboxModal {
  static void show(BuildContext context, {required AppDatabase db}) async {
    final pending = await NotificationBridge.getPendingRawNotifications();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inbox_outlined, color: AppColors.neoChartreuse, size: 22),
                      const SizedBox(width: 8),
                      Text('Kotak Masuk Notifikasi', style: AppTypography.sectionTitle),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Notifikasi bank yang masuk saat aplikasi tidak dibuka ditampung aman di sini:',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
              if (pending.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.canvasInputSearch,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!',
                      textAlign: TextAlign.center,
                      style: AppTypography.listSubtitle,
                    ),
                  ),
                )
              else
                for (final item in pending)
                  Builder(builder: (c) {
                    final pkg = item['package'] as String? ?? '';
                    final title = item['title'] as String? ?? '';
                    final text = item['text'] as String? ?? '';
                    final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pkg.contains('seabank') ? 'SeaBank' : (pkg.contains('shopee') ? 'ShopeePay' : title),
                                style: AppTypography.listTitle,
                              ),
                              if (parsed != null)
                                Text(
                                  parsed.type == 'income'
                                      ? '+Rp ${parsed.amount.toStringAsFixed(0)}'
                                      : '-Rp ${parsed.amount.toStringAsFixed(0)}',
                                  style: AppTypography.listAmount.copyWith(
                                    color: parsed.type == 'income' ? AppColors.neoMint : AppColors.neoCoral,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(text, style: AppTypography.listSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          if (parsed != null)
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neoChartreuse,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Review & Simpan',
                                  style: AppTypography.listTitle.copyWith(
                                    color: AppColors.textDarkPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await NotificationReviewModal.show(context, db: db, parsed: parsed, rawPackage: pkg);
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        );
      },
    );
  }
}
