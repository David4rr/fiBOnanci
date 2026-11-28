import 'package:flutter/material.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../widgets/common/common_widgets.dart';
import '../wallet_screen.dart';

class DashboardEmptyWalletView extends StatelessWidget {
  const DashboardEmptyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 80),
        child: CardlessEmptyView(
          icon: Icons.account_balance_wallet_outlined,
          title: l10n.dashboardEmptyWalletTitle,
          description: l10n.dashboardEmptyWalletDesc,
          hint: l10n.dashboardEmptyWalletHint,
          onTap: () => WalletScreen.showAddWalletModal(context),
        ),
      ),
    );
  }
}
