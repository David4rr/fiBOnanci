import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/subscription_stacked_deck.dart';
import 'subscription/subscription_card_detail_sheet.dart';
import 'subscription/subscription_summary_banner.dart';

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
                        style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textWhite, letterSpacing: -0.6),
                      ),
                      const SizedBox(height: 2),
                      Text('${subscriptions.length} Kartu Terdaftar • Diurutkan jatuh tempo', style: AppTypography.listSubtitle),
                    ],
                  ),
                ),
                if (subscriptions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF13151D), border: Border.all(color: AppColors.canvasBorder, width: 1.5)),
                              child: const Icon(Icons.receipt_long_outlined, color: AppColors.neoCoral, size: 32),
                            ),
                            const SizedBox(height: 18),
                            Text('Belum Ada Tagihan Rutin', style: AppTypography.heroGreeting.copyWith(fontSize: 20)),
                            const SizedBox(height: 8),
                            Text('Daftarkan langganan Netflix, Spotify, listrik PLN, dll agar tercatat rapi.', textAlign: TextAlign.center, style: AppTypography.listSubtitle),
                          ],
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
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                _searchQuery.isNotEmpty ? 'Tidak ada tagihan yang cocok dengan "$_searchQuery"' : 'Tidak ada tagihan dalam filter ini',
                                style: AppTypography.listSubtitle,
                              ),
                            ),
                          )
                        : SubscriptionStackedDeck(
                            subscriptions: filtered,
                            wallets: wallets,
                            onTapCard: (sub, wallet) => SubscriptionCardDetailSheet.show(context, sub, wallet),
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
