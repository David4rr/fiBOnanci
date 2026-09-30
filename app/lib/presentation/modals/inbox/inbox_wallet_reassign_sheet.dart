import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class InboxWalletReassignSheet extends StatefulWidget {
  final AppDatabase db;
  final String? currentWalletId;

  const InboxWalletReassignSheet({
    super.key,
    required this.db,
    this.currentWalletId,
  });

  static Future<WalletEntry?> show(BuildContext context, {required AppDatabase db, String? currentWalletId}) {
    return showModalBottomSheet<WalletEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InboxWalletReassignSheet(db: db, currentWalletId: currentWalletId),
    );
  }

  @override
  State<InboxWalletReassignSheet> createState() => _InboxWalletReassignSheetState();
}

class _InboxWalletReassignSheetState extends State<InboxWalletReassignSheet> {
  List<WalletEntry> _wallets = [];
  List<ProfileEntry> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final wallets = await (widget.db.select(widget.db.wallets)..where((t) => t.isDeleted.equals(false))).get();
    final profiles = await (widget.db.select(widget.db.profiles)..where((t) => t.isDeleted.equals(false))).get();
    if (mounted) {
      setState(() {
        _wallets = wallets;
        _profiles = profiles;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0D11),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
          Text(
            'Pilih Dompet / Workspace',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Alihkan transaksi auto-log ini ke rekening atau akun yang benar.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.48),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _wallets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final w = _wallets[index];
                  final isSelected = w.id == widget.currentWalletId;
                  final prof = _profiles.where((p) => p.id == w.profileId).firstOrNull;

                  return GestureDetector(
                    key: ValueKey('reassign_wallet_${w.id}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(w),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.neoChartreuse.withValues(alpha: 0.08) : const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.neoChartreuse.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.04),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.neoChartreuse : const Color(0xFF232738),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 18,
                              color: isSelected ? Colors.black : Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${prof?.fullName ?? prof?.username ?? 'Akun Utama'} • ${w.accountNumber?.isNotEmpty == true ? w.accountNumber : w.type.toUpperCase()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: isSelected ? AppColors.neoChartreuse : AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.neoChartreuse, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
