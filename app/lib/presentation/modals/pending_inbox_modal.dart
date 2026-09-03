import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';
import 'inbox/inbox_empty_view.dart';
import 'inbox/inbox_header_ribbon.dart';
import 'inbox/inbox_notification_card.dart';
import 'inbox/inbox_simulation_picker.dart';
import 'inbox/spring_swipeable_card.dart';

export 'inbox/inbox_empty_view.dart';
export 'inbox/inbox_header_ribbon.dart';
export 'inbox/inbox_notification_card.dart';
export 'inbox/inbox_simulation_picker.dart';
export 'inbox/spring_swipeable_card.dart';

class PendingInboxModal {
  static Future<void> show(BuildContext context, {AppDatabase? database}) async {
    final initialPending = await NotificationBridge.getPendingRawNotifications();
    if (!context.mounted) return;

    AppDatabase? db = database;
    if (db == null) {
      final repo = context.read<FinanceBloc>().repository;
      if (repo is DriftFinanceRepository) db = repo.db;
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PendingInboxSheet(initialPending: initialPending, database: db),
    );
  }
}

class _PendingInboxSheet extends StatefulWidget {
  final List<Map<String, dynamic>> initialPending;
  final AppDatabase? database;

  const _PendingInboxSheet({required this.initialPending, this.database});

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
    return repo is DriftFinanceRepository ? repo.db : null;
  }

  void _confirmItem(Map<String, dynamic> item) {
    NotificationBridge.confirmNotification(item);
    setState(() => _pending.remove(item));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.canvasCardSurface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.neoMint.withValues(alpha: 0.3))),
          content: Text('Transaksi terkonfirmasi benar', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      );
    }
  }

  void _rejectItem(Map<String, dynamic> item) async {
    final db = _resolveDb();
    if (db != null) await NotificationBridge.rejectNotification(item, db);
    setState(() => _pending.remove(item));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.canvasCardSurface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.neoCoral.withValues(alpha: 0.3))),
          content: Text('Transaksi dibatalkan & saldo dipulihkan', style: GoogleFonts.plusJakartaSans(color: AppColors.neoCoral, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      );
    }
  }

  void _injectNotification(Map<String, dynamic> raw) async {
    final db = _resolveDb();
    if (db == null) return;
    await NotificationBridge.handleRawNotification(raw, db);
    final updated = await NotificationBridge.getPendingRawNotifications();
    if (mounted) setState(() => _pending = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0D11),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 18),
          InboxHeaderRibbon(
            pendingCount: _pending.length,
            onSimulate: () => InboxSimulationPicker.show(context, _injectNotification),
            onRejectFirst: () {
              if (_pending.isNotEmpty) _rejectItem(_pending.first);
            },
            onConfirmFirst: () {
              if (_pending.isNotEmpty) _confirmItem(_pending.first);
            },
          ),
          if (_pending.isEmpty)
            InboxEmptyView(onSimulationTap: () => InboxSimulationPicker.show(context, _injectNotification))
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.58),
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
                  final String bankLabel = pkg.contains('seabank') ? 'SeaBank' : (pkg.contains('shopee') ? 'ShopeePay' : (title.isNotEmpty ? title : 'Notifikasi Bank'));
                  final Color cardAccent = type == 'income' ? AppColors.neoMint : AppColors.neoCoral;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SpringSwipeableCard(
                      key: ValueKey(item['transactionId'] ?? '${pkg}_${text}_$index'),
                      accentColor: cardAccent,
                      onConfirmed: () => _confirmItem(item),
                      onRejected: () => _rejectItem(item),
                      child: InboxNotificationCard(
                        bankLabel: bankLabel,
                        type: type,
                        amount: amount,
                        counterparty: counterparty,
                        walletName: walletName,
                        text: text,
                        cardAccent: cardAccent,
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
