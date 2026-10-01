import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../modals/pocket_detail_modal.dart';
import '../../widgets/bento_folder_card.dart';
import '../../widgets/pocket_stock_chart_card.dart';
import '../../widgets/pocket_card_theme.dart';
import '../../widgets/common/common_widgets.dart';

class WalletPocketsView extends StatelessWidget {
  final List<PocketEntry> pockets;
  final double totalPocketsAmount;
  final List<TransactionEntry> transactions;
  final NumberFormat currencyFormatter;

  const WalletPocketsView({
    super.key,
    required this.pockets,
    required this.totalPocketsAmount,
    required this.transactions,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    if (pockets.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 80),
            child: CardlessEmptyView(
              icon: Icons.savings_outlined,
              title: 'Belum Ada Kantong Tabungan',
              description: 'Pisahkan dana untuk Tabungan, Dana Darurat, atau Impianmu agar aman dari belanja harian.',
              hint: 'Ketuk tombol + di bawah untuk membuat',
            ),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PocketStockChartCard(
              currentTotal: totalPocketsAmount,
              pocketsCount: pockets.length,
              transactions: transactions,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 148,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pocket = pockets[index];
                final config = PocketCardThemeConfig.resolve(pocket, index, allPockets: pockets);
                final target = pocket.targetAmount;
                final current = pocket.currentAmount;

                return BentoFolderCard(
                  backgroundColor: config.backgroundColor,
                  textColor: config.primaryTextColor,
                  subtitleColor: config.secondaryTextColor,
                  iconColor: config.iconColor,
                  iconBgColor: config.iconBgColor,
                  height: 148,
                  iconData: getPocketIcon(pocket.type),
                  title: currencyFormatter.format(current),
                  subtitleWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pocket.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: config.secondaryTextColor,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        target != null && target > 0 ? 'Target ${currencyFormatter.format(target)}' : 'Tanpa target',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: config.tertiaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  onTap: () => PocketDetailModal.show(context, pocket: pocket),
                );
              },
              childCount: pockets.length,
            ),
          ),
        ),
      ],
    );
  }
}
