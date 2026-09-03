import 'package:flutter/material.dart';
import '../../../core/native_bridge/notification_bridge.dart';
import '../../modals/pending_inbox_modal.dart';
import '../../modals/profile_modal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/profile_avatar.dart';

class DashboardHeader extends StatelessWidget {
  final String username;
  final String? avatarPath;
  final int walletCount;
  final int txCount;

  const DashboardHeader({
    super.key,
    required this.username,
    this.avatarPath,
    required this.walletCount,
    required this.txCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello $username', style: AppTypography.heroGreeting),
                const SizedBox(height: 2),
                Text('Selamat datang kembali!', style: AppTypography.listSubtitle),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => PendingInboxModal.show(context),
                child: ValueListenableBuilder<int>(
                  valueListenable: NotificationBridge.pendingCountNotifier,
                  builder: (context, pendingCount, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E212D),
                            border: Border.all(color: AppColors.canvasBorder, width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.inbox_outlined, color: AppColors.textWhite, size: 20),
                          ),
                        ),
                        if (pendingCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.neoChartreuse,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.canvasBg, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ProfileModal.show(context, walletCount: walletCount, txCount: txCount),
                child: ProfileAvatar(avatarPath: avatarPath, name: username, size: 42),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
