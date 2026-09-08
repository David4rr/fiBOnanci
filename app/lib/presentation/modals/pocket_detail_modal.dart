import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
import 'pocket/pocket_detail_tab.dart';
import 'pocket/pocket_detail_views.dart';
import 'pocket/pocket_transfer_dialog.dart';
import 'pocket/pocket_transfer_form.dart';

export 'pocket/pocket_detail_tab.dart';
export 'pocket/pocket_detail_views.dart';
export 'pocket/pocket_transfer_dialog.dart';
export 'pocket/pocket_transfer_form.dart';

class PocketDetailModal {
  static void show(
    BuildContext context, {
    required PocketEntry pocket,
    int initialTab = 0,
    bool initialIsDeposit = true,
  }) {
    final financeBloc = context.read<FinanceBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: financeBloc,
          child: PocketDetailSheet(
            pocket: pocket,
            initialTab: initialTab,
            initialIsDeposit: initialIsDeposit,
          ),
        );
      },
    );
  }

  static void showTransferDialog(BuildContext context, {required PocketEntry pocket, required bool isDeposit}) {
    show(context, pocket: pocket, initialTab: 1, initialIsDeposit: isDeposit);
  }
}

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

  void _goToDetails() {
    setState(() => _currentTab = 0);
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
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
                title: _currentTab == 0
                    ? latestPocket.name
                    : (_isDeposit ? 'Isi Dana ke Kantong' : 'Tarik Dana ke Rekening'),
                subtitle: _currentTab == 0
                    ? '${getPocketTypeLabel(latestPocket.type)} • Target: ${_currencyFormatter.format(latestPocket.targetAmount)}'
                    : (_isDeposit
                        ? 'Pilih rekening asal untuk memindahkan dana ke ${latestPocket.name}.'
                        : 'Pilih rekening tujuan penarikan dari ${latestPocket.name}.'),
                closeIcon: _currentTab == 0
                    ? Icons.keyboard_arrow_down_rounded
                    : (widget.initialTab == 1 ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_left_rounded),
                onClose: () {
                  if (_currentTab == 0 || widget.initialTab == 1) {
                    Navigator.of(context).pop();
                  } else {
                    _goToDetails();
                  }
                },
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
                    ),
                    ColoredBox(
                      color: AppColors.canvasCardSurface,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
                        child: PocketTransferForm(
                          pocket: latestPocket,
                          isDeposit: _isDeposit,
                          onSuccess: () {
                            if (widget.initialTab == 1) {
                              Navigator.of(context).pop();
                            } else {
                              _goToDetails();
                            }
                          },
                          onCancel: () {
                            if (widget.initialTab == 1) {
                              Navigator.of(context).pop();
                            } else {
                              _goToDetails();
                            }
                          },
                        ),
                      ),
                    ),
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
