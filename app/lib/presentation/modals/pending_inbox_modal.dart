import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import 'inbox/pending_inbox_sheet.dart';

export 'inbox/inbox_cards_list.dart';
export 'inbox/inbox_edit_transaction_sheet.dart';
export 'inbox/inbox_empty_view.dart';
export 'inbox/inbox_header_ribbon.dart';
export 'inbox/inbox_notification_card.dart';
export 'inbox/inbox_stacked_deck.dart';
export 'inbox/inbox_wallet_chip.dart';
export 'inbox/inbox_wallet_reassign_sheet.dart';
export 'inbox/pending_inbox_sheet.dart';
export 'inbox/spring_swipeable_card.dart';

class PendingInboxModal {
  static Future<void> show(BuildContext context, {AppDatabase? database}) async {
    final initialPending = await NotificationBridge.getPendingRawNotifications();
    if (!context.mounted) return;

    AppDatabase? db = database;
    if (db == null) {
      final repo = context.read<FinanceBloc>().repository;
      if (repo is DriftFinanceRepository) db = repo.db;
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      builder: (ctx) => PendingInboxSheet(initialPending: initialPending, database: db),
    );
  }
}
