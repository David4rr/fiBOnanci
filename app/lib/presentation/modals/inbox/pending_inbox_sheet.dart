import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../core/native_bridge/notification_bridge.dart';
import '../../../core/notifications/in_app_notification_storage.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'inbox_header_ribbon.dart';
import 'inbox_inline_edit_form.dart';
import 'inbox_reminders_view.dart';
import 'inbox_review_deck_view.dart';
import 'inbox_tab_selector.dart';
import 'inbox_wallet_reassign_sheet.dart';

class PendingInboxSheet extends StatefulWidget {
  final List<Map<String, dynamic>> initialPending;
  final AppDatabase? database;

  const PendingInboxSheet({super.key, required this.initialPending, this.database});

  @override
  State<PendingInboxSheet> createState() => _PendingInboxSheetState();
}

class _PendingInboxSheetState extends State<PendingInboxSheet> {
  late List<Map<String, dynamic>> _pending;
  bool _isEditing = false;
  Map<String, dynamic>? _editingItem;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _pending = List<Map<String, dynamic>>.from(widget.initialPending);
    if (_pending.isEmpty && InAppNotificationStorage.unreadCountNotifier.value > 0) {
      _selectedTab = 1;
    }
  }

  AppDatabase? _resolveDb() {
    if (widget.database != null) return widget.database;
    final repo = context.read<FinanceBloc>().repository;
    return repo is DriftFinanceRepository ? repo.db : null;
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    if (color == AppColors.neoMint) {
      AppSnackBar.showSuccess(context, msg, tag: 'INBOX');
    } else {
      AppSnackBar.showError(context, msg, tag: 'INBOX');
    }
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

  void _reassignWallet(Map<String, dynamic> item) async {
    final db = _resolveDb();
    if (db == null) return;
    final msg = await InboxWalletReassignSheet.reassignItem(context, db: db, item: item);
    if (msg != null && mounted) {
      setState(() {});
      _showSnack(msg, AppColors.neoChartreuse);
    }
  }

  void _editItem(Map<String, dynamic> item) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _editingItem = item;
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _editingItem = null;
      _isEditing = false;
    });
  }

  void _saveEdit(Map<String, dynamic> res) async {
    final item = _editingItem;
    if (item == null) return;
    final db = _resolveDb();

    final newAmt = (res['amount'] as num).toDouble();
    final newType = res['type'] as String;
    final newNotes = res['counterparty'] as String;

    final txId = item['transactionId'] as String?;
    if (txId != null && db != null) {
      final tx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingleOrNull();
      if (tx != null) {
        await db.updateTransactionWithWalletReassignment(
          txId: txId,
          newWalletId: tx.walletId,
          newAmount: newAmt,
          newType: newType,
          newCategoryId: tx.categoryId,
          newDestinationWalletId: tx.destinationWalletId,
          newNotes: newNotes,
        );
      }
    }

    setState(() {
      item['amount'] = newAmt;
      item['type'] = newType;
      item['counterparty'] = newNotes;
      _editingItem = null;
      _isEditing = false;
    });
    NotificationInbox.updatePending(item);
    _showSnack('Transaksi berhasil disesuaikan', AppColors.neoMint);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final modalHeight = (screenHeight * 0.82).clamp(480.0, 750.0);

    return Container(
      height: modalHeight,
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
          InboxHeaderRibbon(pendingCount: _pending.length),
          ValueListenableBuilder<int>(
            valueListenable: InAppNotificationStorage.unreadCountNotifier,
            builder: (context, unreadCount, _) => InboxTabSelector(
              selectedTab: _selectedTab,
              pendingCount: _pending.length,
              unreadCount: unreadCount,
              onTabSelected: (idx) => setState(() => _selectedTab = idx),
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? AnimatedCrossFade(
                    duration: const Duration(milliseconds: 260),
                    firstCurve: Curves.easeOutCubic,
                    secondCurve: Curves.easeInCubic,
                    crossFadeState: _isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: InboxReviewDeckView(
                      pending: _pending,
                      onConfirm: _confirmItem,
                      onReject: _rejectItem,
                      onReassign: _reassignWallet,
                      onEdit: _editItem,
                    ),
                    secondChild: _buildInlineEdit(),
                  )
                : const InboxRemindersView(),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineEdit() {
    final item = _editingItem;
    if (item == null) return const SizedBox.shrink();
    return InboxInlineEditForm(
      initialAmount: (item['amount'] as num?)?.toDouble() ?? 0.0,
      initialType: (item['type'] as String?) ?? 'expense',
      initialCounterparty: (item['counterparty'] as String?) ?? '',
      walletName: item['walletName'] as String?,
      onSave: _saveEdit,
      onCancel: _cancelEdit,
    );
  }
}
