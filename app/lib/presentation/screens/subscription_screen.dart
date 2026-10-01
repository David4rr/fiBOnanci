import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/subscription_stacked_deck.dart';
import 'subscription/subscription_card_detail_sheet.dart';
import 'subscription/subscription_summary_banner.dart';
import '../widgets/common/common_widgets.dart';

export 'subscription/subscription_card_detail_sheet.dart';
export 'subscription/subscription_summary_banner.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback? onAddSubscription;

  const SubscriptionScreen({super.key, this.onAddSubscription});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _filter = 'all';
  String? _walletFilter;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final subscriptions = state.subscriptions;
            final wallets = state.wallets;

            final filtered = subscriptions.where((sub) {
              final isPaid = sub.lastPaidDate != null &&
                  sub.lastPaidDate!.year == now.year &&
                  sub.lastPaidDate!.month == now.month;

              if (_filter == 'unpaid' && isPaid) return false;
              if (_filter == 'paid' && !isPaid) return false;
              if (_walletFilter != null && sub.walletId != _walletFilter) return false;

              if (_searchQuery.isNotEmpty) {
                final matchTitle = sub.title.toLowerCase().contains(_searchQuery.toLowerCase());
                final wallet = wallets.firstWhere((w) => w.id == sub.walletId, orElse: () => wallets.first);
                final matchWallet = wallet.name.toLowerCase().contains(_searchQuery.toLowerCase());
                return matchTitle || matchWallet;
              }
              return true;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tagihan & Langganan',
                        style: AppTypography.modalTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subscriptions.length} Kartu Terdaftar • Diurutkan jatuh tempo',
                        style: AppTypography.modalSubtitle,
                      ),
                    ],
                  ),
                ),
                if (subscriptions.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 80),
                        child: CardlessEmptyView(
                          icon: Icons.receipt_long_outlined,
                          title: 'Belum Ada Tagihan Rutin',
                          description: 'Daftarkan langganan Netflix, Spotify, atau cicilan agar jatuh tempo tercatat rapi.',
                          hint: 'Ketuk tombol + di bawah untuk menambahkan',
                        ),
                      ),
                    ),
                  )
                else ...[
                  SubscriptionSearchBar(
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    filter: _filter,
                    walletFilter: _walletFilter,
                    wallets: wallets,
                    onSearchChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    onClearSearch: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    onFilterApplied: (status, walletId) => setState(() {
                      _filter = status;
                      _walletFilter = walletId;
                    }),
                    onClearStatusFilter: () => setState(() => _filter = 'all'),
                    onClearWalletFilter: () => setState(() => _walletFilter = null),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                              child: CardlessEmptyView(
                                icon: Icons.search_off_rounded,
                                title: 'Tagihan Tidak Ditemukan',
                                description: _searchQuery.isNotEmpty
                                    ? 'Tidak ada tagihan yang cocok dengan "$_searchQuery".'
                                    : 'Tidak ada tagihan dalam filter ini.',
                              ),
                            ),
                          )
                        : SubscriptionStackedDeck(
                            subscriptions: filtered,
                            wallets: wallets,
                            onTapCard: (sub, wallet, index) => SubscriptionCardDetailSheet.show(context, sub, wallet, indexOverride: index),
                          ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
