import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/pocket_card_theme.dart';
import '../../widgets/transaction_detail_modal.dart';
import 'pocket_detail_tab.dart';
import 'pocket_detail_views.dart';
import 'pocket_transfer_form.dart';

class PocketDetailSheet extends StatefulWidget {
  final PocketEntry pocket;
  final int initialTab;
  final bool initialIsDeposit;
  const PocketDetailSheet({super.key, required this.pocket, this.initialTab = 0, this.initialIsDeposit = true});

  @override
  State<PocketDetailSheet> createState() => _PocketDetailSheetState();
}

class _PocketDetailSheetState extends State<PocketDetailSheet> {
  final _sheetKey = GlobalKey<ExpandableModalSheetState>();
  late final PageController _pageController;
  late int _currentTab, _subTab;
  late bool _isDeposit;
  TransactionEntry? _selectedTransaction;
  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _subTab = widget.initialTab != 0 ? widget.initialTab : 1;
    _isDeposit = widget.initialIsDeposit;
    _pageController = PageController(initialPage: widget.initialTab == 0 ? 0 : 1);
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }
  void _goToTransfer({required bool isDeposit}) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() { _isDeposit = isDeposit; _subTab = 1; _currentTab = 1; });
    SmoothPageView.animateTo(_pageController, 1);
  }

  void _goToEditTx(TransactionEntry tx) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() { _selectedTransaction = tx; _subTab = 2; _currentTab = 2; });
    SmoothPageView.animateTo(_pageController, 1);
  }

  void _goToDetails() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentTab = 0);
    SmoothPageView.animateTo(_pageController, 0);
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
    final target = latestPocket.targetAmount;
    if (target != null && target > 0) {
      return '${getPocketTypeLabel(latestPocket.type)} • Target: ${AppCurrency.read(context).format(target)}';
    }
    return getPocketTypeLabel(latestPocket.type);
  }
  IconData get _closeIcon => (_currentTab == 0 || (widget.initialTab == 1 && _currentTab == 1))
      ? Icons.keyboard_arrow_down_rounded
      : Icons.keyboard_arrow_left_rounded;

  void _handleClose() => (_currentTab == 0 || (widget.initialTab == 1 && _currentTab == 1))
      ? Navigator.of(context).pop()
      : _goToDetails();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final latestPocket = state.pockets.firstWhere((p) => p.id == widget.pocket.id, orElse: () => widget.pocket);
        final pocketIdx = state.pockets.indexWhere((p) => p.id == latestPocket.id);
        final themeConfig = PocketCardThemeConfig.resolve(latestPocket, pocketIdx >= 0 ? pocketIdx : 0, allPockets: state.pockets);
        final pocketColor = themeConfig.backgroundColor;
        final pocketTxs = state.transactions.where((tx) {
          if (tx.externalRef == 'pocket_${latestPocket.id}') return true;
          final n = (tx.notes ?? '').toLowerCase();
          final nameLower = latestPocket.name.toLowerCase();
          return n.contains(nameLower) || (n.contains('kantong') && tx.walletId == latestPocket.linkedWalletId);
        }).toList();

        final canPop = _currentTab == 0 || (widget.initialTab == 1 && _currentTab == 1);
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _goToDetails();
          },
          child: ExpandableModalSheet(
            key: _sheetKey,
            initialChildSize: 1.0,
            minChildSize: 0.25,
            maxChildSize: 1.0,
            snapSizes: const [1.0],
            backgroundColor: AppColors.canvasBg,
            builder: (ctx, scrollController, currentSize) {
              return Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: (d) => _sheetKey.currentState?.handleHeaderDragStart(d),
                    onVerticalDragUpdate: (d) => _sheetKey.currentState?.handleHeaderDragUpdate(d),
                    onVerticalDragEnd: (d) => _sheetKey.currentState?.handleHeaderDragEnd(d),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _currentTab == 0
                            ? const ModalGrabHandle(padding: EdgeInsets.only(top: 10, bottom: 6))
                            : const SizedBox(height: 20),
                        ModalHeader(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                          title: _getTitle(latestPocket),
                          subtitle: _getSubtitle(latestPocket),
                          closeIcon: _closeIcon,
                          onClose: _handleClose,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SmoothPageView(
                      controller: _pageController,
                      children: [
                        PocketDetailTab(
                          pocket: latestPocket,
                            pocketColor: pocketColor,
                            themeConfig: themeConfig,
                            transactions: pocketTxs,
                            wallets: state.wallets,
                            currencyFormatter: AppCurrency.forCode(state.profile.currency),
                            onDeposit: () => _goToTransfer(isDeposit: true),
                            onWithdraw: () => _goToTransfer(isDeposit: false),
                            onEditTransaction: _goToEditTx,
                        ),
                        (_subTab == 2 && _selectedTransaction != null)
                            ? TransactionDetailModal(
                                  key: ValueKey(_selectedTransaction!.id),
                                  transaction: _selectedTransaction!,
                                  isInline: true,
                                  onClose: _goToDetails,
                                  onSaved: _goToDetails,
                                  onDeleted: _goToDetails,
                                )
                              : SingleChildScrollView(
                                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
                                  child: PocketTransferForm(
                                    key: ValueKey('transfer_${_isDeposit}_${latestPocket.id}'),
                                    pocket: latestPocket,
                                    isDeposit: _isDeposit,
                                    onSuccess: _handleClose,
                                    onCancel: _handleClose,
                                  ),
                              ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
