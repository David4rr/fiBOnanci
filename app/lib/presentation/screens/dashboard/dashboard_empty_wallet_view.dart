import 'package:flutter/material.dart';

import '../../widgets/common/common_widgets.dart';
import '../wallet_screen.dart';

class DashboardEmptyWalletView extends StatelessWidget {
  const DashboardEmptyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
          child: CardlessEmptyView(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Belum Ada Rekening Terhubung',
            description: 'Tambahkan rekening atau dompet digital untuk mulai melacak keuangan dan alokasi safe-to-spend.',
            hint: 'Ketuk tombol + di bawah untuk menambahkan',
            onTap: () => WalletScreen.showAddWalletModal(context),
          ),
        ),
      ),
    );
  }
}
