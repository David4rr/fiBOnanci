import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../subscription_detail/subscription_detail_screen.dart';

export '../subscription_detail/subscription_detail_screen.dart';

/// Backward-compatible wrapper delegating to full-screen [SubscriptionDetailScreen.show].
class SubscriptionCardDetailSheet {
  static Future<void> show(
    BuildContext context,
    SubscriptionEntry sub,
    WalletEntry wallet, {
    int? indexOverride,
    double initialChildSize = 1.0,
  }) {
    return SubscriptionDetailScreen.show(
      context,
      subscription: sub,
      wallet: wallet,
      indexOverride: indexOverride,
      initialChildSize: initialChildSize,
    );
  }
}
