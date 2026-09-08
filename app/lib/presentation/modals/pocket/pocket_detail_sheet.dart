import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/transaction_detail_modal.dart';
import 'pocket_detail_tab.dart';
import 'pocket_detail_views.dart';
import 'pocket_transfer_form.dart';

class PocketDetailSheet extends StatefulWidget {
  final PocketEntry pocket;
  final int initialTab;
  final bool initialIsDeposit;

  const PocketDetailSheet({
    super.key,
    required this.pocket,
    this.initialTab = 0,
    this.initialIsDeposit = true,
  });

  @override
  State<PocketDetailSheet> createState() => _PocketDetailSheetState();
}

class _PocketDetailSheetState extends State<PocketDetailSheet> {
  late final PageController _pageController;
  late int _currentTab;
  late bool _isDeposit;
  TransactionEntry? _selectedTransaction;
  final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _isDeposit = widget.initialIsDeposit;
    _pageController = PageController(initialPage: widget.initialTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTransfer({required bool isDeposit}) {
    setState(() {
      _isDeposit = isDeposit;
      _currentTab = 1;
    });
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  void _goToEditTx(TransactionEntry tx) {
    setState(() {
      _selectedTransaction = tx;
      _currentTab = 2;
    });
    _pageController.animateToPage(2, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  void _goToDetails() {
    setState(() {
      _currentTab = 0;
      _selectedTransaction = null;
    });
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  String _getTitle(PocketEntry latestPocket) {
    if (_currentTab == 1) return _isDeposit ? 'Isi Dana ke Kantong' : 'Tarik Dana ke Rekening';
    if (_currentTab == 2) return 'Edit Transaksi';
    return latestPocket.name;
  }

  String _getSubtitle(PocketEntry latestPocket) {
    if (_currentTab == 1) {
      return _isDeposit
          ? 'Pilih rekening asal untuk memindahkan dana ke ${latestPocket.name}.'
          : 'Pilih rekening tujuan penarikan dari ${latestPocket.name}.';
    }
    if (_currentTab == 2) {
      final notes = _selectedTransaction?.notes?.trim();
      return notes != null && notes.isNotEmpty ? notes : 'Ubah rincian mutasi transaksi';
    }
    return '${getPocketTypeLabel(latestPocket.type)} • Target: ${_currencyFormatter.format(latestPocket.targetAmount)}';
  }

  IconData get _closeIcon {
    if (_currentTab == 0 || (widget.initialTab == 1 && _currentTab == 1)) {
      return Icons.keyboard_arrow_down_rounded;
    }
    return Icons.keyboard_arrow_left_rounded;
  }

  void _handleClose() {
    if (_currentTab == 0 || (widget.initialTab == 1 && _currentTab == 1)) {
      Navigator.of(context).pop();
    } else {
      _goToDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final latestPocket = state.pockets.firstWhere((p) => p.id == widget.pocket.id, orElse: () => widget.pocket);
        final pocketColor = Color(int.parse(latestPocket.colorHex.replaceAll('#', '0xFF')));
        final pocketTxs = state.transactions.where((tx) {
          final n = (tx.notes ?? '').toLowerCase();
          final nameLower = latestPocket.name.toLowerCase();
          return n.contains(nameLower) || (n.contains('kantong') && tx.walletId == latestPocket.linkedWalletId);
        }).toList();

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.88,
          child: Column(
            children: [
              const ModalGrabHandle(padding: EdgeInsets.only(top: 12, bottom: 8)),
              ModalHeader(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                title: _getTitle(latestPocket),
                subtitle: _getSubtitle(latestPocket),
                closeIcon: _closeIcon,
                onClose: _handleClose,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    PocketDetailTab(
                      pocket: latestPocket,
                      pocketColor: pocketColor,
                      transactions: pocketTxs,
                      wallets: state.wallets,
                      currencyFormatter: _currencyFormatter,
                      onDeposit: () => _goToTransfer(isDeposit: true),
                      onWithdraw: () => _goToTransfer(isDeposit: false),
                      onEditTransaction: _goToEditTx,
                    ),
                    ColoredBox(
                      color: AppColors.canvasCardSurface,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
                        child: PocketTransferForm(
                          pocket: latestPocket,
                          isDeposit: _isDeposit,
                          onSuccess: () => widget.initialTab == 1 ? Navigator.of(context).pop() : _goToDetails(),
                          onCancel: () => widget.initialTab == 1 ? Navigator.of(context).pop() : _goToDetails(),
                        ),
                      ),
                    ),
                    if (_selectedTransaction != null)
                      TransactionDetailModal(
                        key: ValueKey(_selectedTransaction!.id),
                        transaction: _selectedTransaction!,
                        isInline: true,
                        onClose: _goToDetails,
                        onSaved: _goToDetails,
                        onDeleted: _goToDetails,
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
