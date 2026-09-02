import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Compact modal sheet for reviewing auto-logged notifications with interactive simulation.
/// Swipe RIGHT → Correct (Benar / Simpan).
/// Swipe LEFT  → Incorrect (Salah / Hapus transaksi & kembalikan saldo).
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
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
          backgroundColor: AppColors.neoMint,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.textDarkPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Transaksi terkonfirmasi benar',
                style: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
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
          backgroundColor: AppColors.neoCoral,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.textWhite, size: 20),
              SizedBox(width: 8),
              Text(
                'Transaksi dihapus & saldo dikembalikan',
                style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
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
          backgroundColor: AppColors.neoChartreuse,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.textDarkPrimary, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Notifikasi simulasi berhasil masuk! Geser kartu untuk review.',
                  style: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold, fontSize: 12.5),
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
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSubtle.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.neoChartreuse, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Pilih Skenario Notifikasi',
                    style: AppTypography.sectionTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih salah satu skenario untuk disimulasikan langsung ke Inbox & Saldo Anda.',
              style: AppTypography.listSubtitle.copyWith(fontSize: 11.5),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.50,
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

                  return Material(
                    color: AppColors.canvasInputSearch,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _injectNotification(payload);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: col.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                col == AppColors.neoMint ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: col,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bank, style: AppTypography.listTitle.copyWith(fontSize: 13.5)),
                                  const SizedBox(height: 2),
                                  Text(desc, style: AppTypography.listSubtitle.copyWith(fontSize: 11.5, color: col)),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_circle_outline_rounded, color: AppColors.neoChartreuse, size: 18),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                color: AppColors.textSubtle.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header with count badge & Simulation trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inbox_outlined, color: AppColors.neoChartreuse, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Kotak Masuk Notifikasi',
                        style: AppTypography.sectionTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_pending.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.neoChartreuse,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_pending.length}',
                          style: AppTypography.badgeLabel.copyWith(
                            color: AppColors.textDarkPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Simulation trigger button in header
              Material(
                color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showSimulationPicker(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.neoChartreuse, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          'Simulasi',
                          style: AppTypography.badgeLabel.copyWith(
                            color: AppColors.neoChartreuse,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Swipe instruction cue
          if (_pending.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.canvasInputSearch,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.canvasBorderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back, size: 12, color: AppColors.neoCoral),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Geser Kiri: Salah',
                            style: AppTypography.badgeLabel.copyWith(color: AppColors.neoCoral, fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('•', style: TextStyle(color: AppColors.textSubtle, fontSize: 10)),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            'Geser Kanan: Benar',
                            style: AppTypography.badgeLabel.copyWith(color: AppColors.neoMint, fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward, size: 12, color: AppColors.neoMint),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_pending.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.canvasInputSearch,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.canvasBorderSubtle),
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.neoMint.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline, color: AppColors.neoMint, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!',
                    textAlign: TextAlign.center,
                    style: AppTypography.listSubtitle.copyWith(height: 1.4, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neoChartreuse,
                      foregroundColor: AppColors.textDarkPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.textDarkPrimary),
                    label: Text(
                      'Coba Simulasi Notifikasi Masuk',
                      style: AppTypography.badgeLabel.copyWith(
                        color: AppColors.textDarkPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => _showSimulationPicker(context),
                  ),
                ],
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

                  final itemKey = ValueKey(item['transactionId'] ?? '${pkg}_${text}_$index');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Dismissible(
                        key: itemKey,
                        direction: DismissDirection.horizontal,
                        // Swipe Right -> Correct (Benar)
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.neoMint.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.neoMint.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.neoMint, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Benar',
                                style: AppTypography.listTitle.copyWith(
                                  color: AppColors.neoMint,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Swipe Left -> Incorrect (Salah)
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.neoCoral.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.neoCoral.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Salah',
                                style: AppTypography.listTitle.copyWith(
                                  color: AppColors.neoCoral,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.delete_outline_rounded, color: AppColors.neoCoral, size: 22),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            _confirmItem(item);
                          } else {
                            _rejectItem(item);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.canvasInputSearch,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.canvasBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Source + Badge & Amount
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            bankLabel,
                                            style: AppTypography.listTitle.copyWith(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Auto',
                                            style: AppTypography.badgeLabel.copyWith(
                                              color: AppColors.neoChartreuse,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (amount > 0)
                                    Text(
                                      type == 'income'
                                          ? '+Rp ${amount.toStringAsFixed(0)}'
                                          : '-Rp ${amount.toStringAsFixed(0)}',
                                      style: AppTypography.listAmount.copyWith(
                                        fontSize: 14,
                                        color: type == 'income' ? AppColors.neoMint : AppColors.neoCoral,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Counterparty & Wallet destination info
                              if (walletName != null || counterparty.isNotEmpty)
                                Text(
                                  [
                                    ?walletName,
                                    if (counterparty.isNotEmpty) counterparty,
                                  ].join(' • '),
                                  style: AppTypography.listSubtitle.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              const SizedBox(height: 4),

                              // Notification raw text preview
                              Text(
                                text,
                                style: AppTypography.listSubtitle.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSubtle,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 10),

                              // Compact Action Buttons Bar
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: AppColors.neoCoral.withValues(alpha: 0.4)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        icon: const Icon(Icons.close_rounded, color: AppColors.neoCoral, size: 14),
                                        label: Text(
                                          'Salah',
                                          style: AppTypography.badgeLabel.copyWith(
                                            color: AppColors.neoCoral,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                        onPressed: () => _rejectItem(item),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.neoChartreuse,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        icon: const Icon(Icons.check_rounded, color: AppColors.textDarkPrimary, size: 14),
                                        label: Text(
                                          'Benar',
                                          style: AppTypography.badgeLabel.copyWith(
                                            color: AppColors.textDarkPrimary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                        onPressed: () => _confirmItem(item),
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
