import 'package:flutter/material.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../widgets/wallet_card.dart';

class OnboardingCelebrationCard extends StatelessWidget {
  final String walletName;
  final String walletType;
  final String balanceText;
  final String username;

  const OnboardingCelebrationCard({
    super.key,
    required this.walletName,
    required this.walletType,
    required this.balanceText,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final rawBalance = RupiahInputFormatter.parse(balanceText);
    final wName = walletName.trim().isEmpty ? 'Rekening Utama' : walletName.trim();
    final uName = username.trim().isEmpty ? 'pengguna' : username.trim();

    final previewWallet = WalletEntry(
      id: 'preview_wallet_0',
      name: wName,
      type: walletType,
      currency: 'IDR',
      balance: rawBalance,
      colorHex: walletType == 'cash'
          ? '#10B981'
          : (walletType == 'ewallet' ? '#26D9D9' : '#0060AF'),
      iconName: walletType == 'cash'
          ? 'wallet'
          : (walletType == 'ewallet' ? 'smartphone' : 'landmark'),
      accountNumber: '@$uName',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: false,
    );

    return Hero(
      tag: 'onboarding_primary_wallet_card',
      child: Material(
        color: Colors.transparent,
        child: WalletCard(
          wallet: previewWallet,
          index: 0,
          fmt: AppCurrency.forCode('IDR'),
          cardH: 195,
          showBottomLayout: true,
          animate: false,
        ),
      ),
    );
  }
}
