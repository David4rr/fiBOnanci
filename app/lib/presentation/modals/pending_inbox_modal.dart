import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import 'inbox/inbox_cards_list.dart';
import 'inbox/inbox_empty_view.dart';
import 'inbox/inbox_header_ribbon.dart';
import 'inbox/inbox_simulation_picker.dart';
import 'inbox/inbox_wallet_reassign_sheet.dart';

export 'inbox/inbox_cards_list.dart';
export 'inbox/inbox_empty_view.dart';
export 'inbox/inbox_header_ribbon.dart';
export 'inbox/inbox_notification_card.dart';
export 'inbox/inbox_simulation_picker.dart';
export 'inbox/inbox_wallet_reassign_sheet.dart';
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
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.canvasCardSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: 0.3))),
        content: Text(msg, style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  void _confirmItem(Map<String, dynamic> item) {
    NotificationBridge.confirmNotification(item);
    setState(() => _pending.remove(item));
    _showSnack('Transaksi terkonfirmasi benar', AppColors.neoMint);
  }

  void _rejectItem(Map<String, dynamic> item) async {
    final db = _resolveDb();
    if (db != null) await NotificationBridge.rejectNotification(item, db);
    setState(() => _pending.remove(item));
    _showSnack('Transaksi dibatalkan & saldo dipulihkan', AppColors.neoCoral);
  }

  void _injectNotification(Map<String, dynamic> raw) async {
    final db = _resolveDb();
    if (db == null) return;
    await NotificationBridge.handleRawNotification(raw, db);
    final updated = await NotificationBridge.getPendingRawNotifications();
    if (mounted) setState(() => _pending = updated);
  }

  void _reassignWallet(Map<String, dynamic> item) async {
    final db = _resolveDb();
    if (db == null) return;
    final currentWalletId = item['walletId'] as String?;
    final newWallet = await InboxWalletReassignSheet.show(
      context,
      db: db,
      currentWalletId: currentWalletId,
    );
    if (newWallet == null || newWallet.id == currentWalletId) return;

    final txId = item['transactionId'] as String?;
    if (txId != null) {
      final tx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingleOrNull();
      if (tx != null) {
        await db.updateTransactionWithWalletReassignment(
          txId: txId,
          newWalletId: newWallet.id,
          newAmount: tx.amount,
          newType: tx.type,
          newCategoryId: tx.categoryId,
          newDestinationWalletId: tx.destinationWalletId,
          newNotes: tx.notes,
        );
      }
    }

    ProfileEntry? prof;
    if (newWallet.profileId != null) {
      prof = await (db.select(db.profiles)..where((t) => t.id.equals(newWallet.profileId!))).getSingleOrNull();
    }

    setState(() {
      item['walletId'] = newWallet.id;
      item['walletName'] = newWallet.name;
      item['profileId'] = newWallet.profileId;
      item['profileName'] = prof?.fullName ?? prof?.username;
    });

    final pName = prof?.fullName ?? prof?.username ?? 'Akun Utama';
    _showSnack('Dialihkan ke $pName • ${newWallet.name}', AppColors.neoChartreuse);
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
          const ModalGrabHandle(padding: EdgeInsets.only(bottom: 18)),
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
            InboxCardsList(
              items: _pending,
              onConfirm: _confirmItem,
              onReject: _rejectItem,
              onReassign: _reassignWallet,
            ),
        ],
      ),
    );
  }
}
