import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';

/// Minimalist, high-end modal sheet for reviewing auto-logged notifications.
///
/// Features:
/// - Pure swipe interaction (no clutter buttons on cards)
/// - Color-coded item cards (NeoMint for Income, NeoCoral for Expense)
/// - Spring-physics snap-back animation when item is not fully swiped
///   (applies to both canceling a delete and canceling an accept action)
/// - Clean, minimalist instruction header
/// - Obsidian frosted glass canvas with hairline highlights
class PendingInboxModal {
  static Future<void> show(BuildContext context, {AppDatabase? database}) async {
    final initialPending = await NotificationBridge.getPendingRawNotifications();
    if (!context.mounted) return;

    AppDatabase? db = database;
    if (db == null) {
      final repo = context.read<FinanceBloc>().repository;
      if (repo is DriftFinanceRepository) {
        db = repo.db;
      }
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PendingInboxSheet(
        initialPending: initialPending,
        database: db,
      ),
    );
  }
}

class _PendingInboxSheet extends StatefulWidget {
  final List<Map<String, dynamic>> initialPending;
  final AppDatabase? database;

  const _PendingInboxSheet({
    required this.initialPending,
    this.database,
  });

  @override
  State<_PendingInboxSheet> createState() => _PendingInboxSheetState();
}

class _PendingInboxSheetState extends State<_PendingInboxSheet> {
  late List<Map<String, dynamic>> _pending;

  @override
  void initState() {
    super.initState();
    _pending = List<Map<String, dynamic>>.from(widget.initialPending);
  }

  AppDatabase? _resolveDb() {
    if (widget.database != null) return widget.database;
    final repo = context.read<FinanceBloc>().repository;
    if (repo is DriftFinanceRepository) {
      return repo.db;
    }
    return null;
  }

  void _confirmItem(Map<String, dynamic> item) {
    NotificationBridge.confirmNotification(item);
    setState(() {
      _pending.remove(item);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.canvasCardSurface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.neoMint.withValues(alpha: 0.3)),
          ),
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neoMint.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.neoMint, size: 14),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Transaksi terkonfirmasi benar',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _rejectItem(Map<String, dynamic> item) {
    final txId = item['transactionId'] as String?;
    if (txId != null && txId.isNotEmpty) {
      context.read<FinanceBloc>().add(DeleteTransactionEvent(txId));
    }
    NotificationBridge.removePendingNotification(item);
    setState(() {
      _pending.remove(item);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.canvasCardSurface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.neoCoral.withValues(alpha: 0.3)),
          ),
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neoCoral.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.neoCoral, size: 14),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Transaksi dihapus & saldo dikembalikan',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _injectNotification(Map<String, dynamic> raw) async {
    final db = _resolveDb();
    if (db == null) return;

    await NotificationBridge.handleRawNotification(raw, db);
    final updated = await NotificationBridge.getPendingRawNotifications();

    if (mounted) {
      setState(() {
        _pending = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.canvasCardSurface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.neoChartreuse.withValues(alpha: 0.3)),
          ),
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.bolt_rounded, color: AppColors.neoChartreuse, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notifikasi simulasi berhasil masuk! Geser kartu untuk review.',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showSimulationPicker(BuildContext context) {
    final presets = [
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C0D11),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
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
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
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
                  child: Text(
                    'Pilih Skenario Notifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColors.textWhite,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih salah satu skenario untuk disimulasikan langsung ke Inbox & Saldo Anda.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textMuted,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.52,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: presets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final p = presets[i];
                  final String bank = p['bank'] as String;
                  final String desc = p['desc'] as String;
                  final Color col = p['color'] as Color;
                  final Map<String, dynamic> payload = p['payload'] as Map<String, dynamic>;

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF13151D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: Material(
                      color: const Color(0xFF161822),
                      borderRadius: BorderRadius.circular(14.5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.5),
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          _injectNotification(payload);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: col.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: col.withValues(alpha: 0.2)),
                                ),
                                child: Icon(
                                  col == AppColors.neoMint
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: col,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bank,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textWhite,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      desc,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: col.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.04),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                                ),
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textMuted,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0D11),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header with minimalist Tag, Title, Live Counter & Actions
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Kotak Masuk Notifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.textWhite,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_pending.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.neoChartreuse.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.neoChartreuse,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_pending.length}',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.neoChartreuse,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Simulation trigger button: Minimalist Island Pill
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showSimulationPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.neoChartreuse,
                            size: 11,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Simulasi',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Minimalist Close Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: const Center(
                      child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Cleaned-Up Delete & Accept Instruction Ribbon
          if (_pending.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.025),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Salah / Delete cue & quick-action
                  Flexible(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (_pending.isNotEmpty) {
                            _rejectItem(_pending.first);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_back_rounded,
                                size: 13,
                                color: AppColors.neoCoral,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Salah',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.neoCoral,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center subtle separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 11,
                      ),
                    ),
                  ),

                  // Right side: Benar / Accept cue & quick-action
                  Flexible(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (_pending.isNotEmpty) {
                            _confirmItem(_pending.first);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  'Benar',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.neoMint,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: AppColors.neoMint,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_pending.isEmpty)
            // Empty State: Double-Bezel Ethereal Minimalist Canvas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF13151D),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161822),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                ),
                child: Column(
                  children: [
                    // Concentric Halo Emblem
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.03),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neoMint.withValues(alpha: 0.08),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neoMint.withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.done_all_rounded,
                            color: AppColors.neoMint,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: AppColors.textMuted,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // High-End Nested Island CTA Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _showSimulationPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.neoChartreuse,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neoChartreuse.withValues(alpha: 0.18),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0x1F000000),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  size: 13,
                                  color: AppColors.textDarkPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Coba Simulasi Notifikasi Masuk',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textDarkPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                    letterSpacing: -0.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.58,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pending.length,
                itemBuilder: (context, index) {
                  final item = _pending[index];
                  final pkg = item['package'] as String? ?? '';
                  final title = item['title'] as String? ?? '';
                  final text = item['text'] as String? ?? '';
                  final walletName = item['walletName'] as String?;
                  final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text);

                  final double amount = (item['amount'] as num?)?.toDouble() ?? parsed?.amount ?? 0.0;
                  final String type = (item['type'] as String?) ?? parsed?.type ?? 'expense';
                  final String counterparty = (item['counterparty'] as String?) ?? parsed?.counterparty ?? '';
                  final String bankLabel = pkg.contains('seabank')
                      ? 'SeaBank'
                      : (pkg.contains('shopee') ? 'ShopeePay' : (title.isNotEmpty ? title : 'Notifikasi Bank'));

                  final isIncome = type == 'income';
                  final Color cardAccent = isIncome ? AppColors.neoMint : AppColors.neoCoral;

                  final itemKey = ValueKey(item['transactionId'] ?? '${pkg}_${text}_$index');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SpringSwipeableCard(
                      key: itemKey,
                      accentColor: cardAccent,
                      onConfirmed: () => _confirmItem(item),
                      onRejected: () => _rejectItem(item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF13151D),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cardAccent.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161822),
                            borderRadius: BorderRadius.circular(16.5),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.03),
                              width: 1,
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Color-Code Indicator Stripe
                                Container(
                                  width: 3.5,
                                  decoration: BoxDecoration(
                                    color: cardAccent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Card Body Content (No Action Buttons!)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top Row: Institution + Auto badge & Hero Amount
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      bankLabel,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 13.5,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: -0.2,
                                                        color: AppColors.textWhite,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: cardAccent.withValues(alpha: 0.10),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(
                                                        color: cardAccent.withValues(alpha: 0.20),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      isIncome ? 'MASUK' : 'KELUAR',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        color: cardAccent,
                                                        fontSize: 8.5,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (amount > 0)
                                              Text(
                                                isIncome
                                                    ? '+Rp ${amount.toStringAsFixed(0)}'
                                                    : '-Rp ${amount.toStringAsFixed(0)}',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.3,
                                                  fontFeatures: const [FontFeature.tabularFigures()],
                                                  color: isIncome ? AppColors.neoMint : AppColors.neoCoral,
                                                ),
                                              ),
                                          ],
                                        ),

                                        // Counterparty & Destination Wallet
                                        if (walletName != null || counterparty.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                if (counterparty.isNotEmpty)
                                                  Flexible(
                                                    child: Text(
                                                      counterparty,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textWhite.withValues(alpha: 0.85),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                if (counterparty.isNotEmpty && walletName != null)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                                    child: Text(
                                                      '•',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors.textSubtle.withValues(alpha: 0.8),
                                                      ),
                                                    ),
                                                  ),
                                                if (walletName != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.04),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      walletName,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                        // Subdued Raw Text Notification
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            text,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textSubtle,
                                              height: 1.35,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// A swipeable card wrapper that executes a realistic spring physics simulation
/// when the user releases before the dismiss threshold (canceling either a delete
/// or an accept action).
class _SpringSwipeableCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final VoidCallback onConfirmed;
  final VoidCallback onRejected;

  const _SpringSwipeableCard({
    super.key,
    required this.child,
    required this.accentColor,
    required this.onConfirmed,
    required this.onRejected,
  });

  @override
  State<_SpringSwipeableCard> createState() => _SpringSwipeableCardState();
}

class _SpringSwipeableCardState extends State<_SpringSwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(() {
      setState(() {
        _dragOffset = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    setState(() {
      _dragOffset += details.primaryDelta ?? 0.0;
      _controller.value = _dragOffset;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final threshold = screenWidth * 0.50;

    // Only trigger when swiped at least 50% of screen width
    if (_dragOffset >= threshold) {
      _dismissRight();
    } else if (_dragOffset <= -threshold) {
      _dismissLeft();
    } else {
      // Less than 50% of screen width: treat as cancel and spring back
      _snapBackWithSpring(velocity);
    }
  }

  void _snapBackWithSpring(double velocity) {
    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1.0,
        stiffness: 420.0,
        damping: 24.0,
      ),
      _dragOffset,
      0.0,
      velocity,
    );
    _controller.animateWith(simulation);
  }

  void _dismissRight() {
    final target = MediaQuery.sizeOf(context).width;
    _controller
        .animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    )
        .then((_) {
      if (mounted) {
        widget.onConfirmed();
      }
    });
  }

  void _dismissLeft() {
    final target = -MediaQuery.sizeOf(context).width;
    _controller
        .animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    )
        .then((_) {
      if (mounted) {
        widget.onRejected();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDraggingRight = _dragOffset > 0;
    final isDraggingLeft = _dragOffset < 0;
    final threshold = MediaQuery.sizeOf(context).width * 0.50;
    final progress = (_dragOffset.abs() / threshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Background Swipe Reveals
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Confirm Reveal (Swiping Right)
                  if (isDraggingRight)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.neoMint.withValues(alpha: 0.12 * progress),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.neoMint.withValues(alpha: 0.35 * progress),
                            width: 1,
                          ),
                        ),
                        child: Opacity(
                          opacity: (progress * 1.2).clamp(0.0, 1.0),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.neoMint.withValues(alpha: 0.2),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.neoMint,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Benar',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.neoMint,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Reject Reveal (Swiping Left)
                  if (isDraggingLeft)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.neoCoral.withValues(alpha: 0.12 * progress),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.neoCoral.withValues(alpha: 0.35 * progress),
                            width: 1,
                          ),
                        ),
                        child: Opacity(
                          opacity: (progress * 1.2).clamp(0.0, 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Salah',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.neoCoral,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.neoCoral.withValues(alpha: 0.2),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.neoCoral,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Foreground Card with Translation
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
