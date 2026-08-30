import '../widgets/bottom_nav_dock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../modals/financial_health_modal.dart';
import '../widgets/notification_review_modal.dart';
import '../../core/native_bridge/notification_bridge.dart';
import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/notification_simulator_modal.dart';
import '../widgets/subscription_modal.dart';
import '../widgets/transaction_modal.dart';
import 'dashboard_screen.dart';
import 'subscription_screen.dart';
import 'wallet_screen.dart';

class MainShell extends StatefulWidget {
  final AppDatabase db;

  const MainShell({super.key, required this.db});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _bridge = NotificationBridge();

  @override
  void initState() {
    super.initState();
    _bridge.startListening(
      widget.db,
      onReviewPrompt: (parsed, pkg) {
        return NotificationReviewModal.show(
          context,
          parsed: parsed,
          rawPackage: pkg,
        );
      },
      onAutoLogged: (msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.neoMint,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.textDarkPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifikasi Otomatis Tercatat!\n$msg',
                      style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _bridge.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToWallets: () => setState(() => _currentIndex = 2),
      ),
      SubscriptionScreen(
        onAddSubscription: () => AddSubscriptionModal.show(context),
      ),
      const WalletScreen(),
      _buildSettingsScreen(context),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      extendBody: true,
      body: screens[_currentIndex < screens.length ? _currentIndex : 0],
      bottomNavigationBar: BottomNavDock(
        currentIndex: _currentIndex,
        onTapIndex: (index) => setState(() => _currentIndex = index),
        onCenterAction: _onCenterAction,
      ),
    );
  }

  void _onCenterAction() {
    switch (_currentIndex) {
      case 0:
        TransactionModal.show(context);
        break;
      case 1:
        AddSubscriptionModal.show(context);
        break;
      case 2:
        WalletScreen.showAddWalletModal(context);
        break;
      case 3:
        NotificationSimulatorModal.show(context);
        break;
    }
  }
  Widget _buildSettingsScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      appBar: AppBar(
        backgroundColor: AppColors.canvasBg,
        elevation: 0,
        title: Text('Pengaturan & Fitur', style: AppTypography.sectionTitle),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
          // Financial Health Check Hero Card
          BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, state) {
              final report = state.healthReport;
              final tierColor = report.tierColor;

              return GestureDetector(
                onTap: () => FinancialHealthModal.show(context),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tierColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: tierColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${report.overallScore}',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AUDIT KESEHATAN FINANSIAL',
                                  style: AppTypography.badgeLabel.copyWith(color: tierColor),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tierColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    report.tierLabel.toUpperCase(),
                                    style: TextStyle(
                                      color: tierColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              report.tierHeadline,
                              style: AppTypography.listTitle.copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dana Darurat: ${report.emergencyRunway.displayValue} • Tagihan: ${report.fixedCommitment.displayValue}',
                              style: AppTypography.listSubtitle.copyWith(fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: tierColor),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // Notification Simulator Feature Card
          GestureDetector(
            onTap: () => NotificationSimulatorModal.show(context),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.neoChartreuse.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.neoChartreuse,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.flash_on, color: AppColors.textDarkPrimary, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIMULATOR NOTIFIKASI BANK',
                          style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tes Parsing Otomatis',
                          style: AppTypography.listTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Uji coba BCA, blu, Mandiri, Jago, SeaBank, OVO',
                          style: AppTypography.listSubtitle,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.neoChartreuse),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Offline Status & System Diagnostics
          Text('STATUS SISTEM OFFLINE', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.canvasCardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: Column(
              children: [
                _buildDiagnosticRow('Engine Database', 'SQLite 3 (Drift ORM)'),
                const Divider(color: AppColors.canvasBorder, height: 20),
                _buildDiagnosticRow('Penyimpanan Data', '100% On-Device Local Storage'),
                const Divider(color: AppColors.canvasBorder, height: 20),
                _buildDiagnosticRow('Sync Status', 'Pending Cloud Config (Render/Supabase)'),
                const Divider(color: AppColors.canvasBorder, height: 20),
                _buildDiagnosticRow('Versi Aplikasi', '1.0.0 (Android MVP)'),
              ],
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
    ),
  );
}

  Widget _buildDiagnosticRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.listSubtitle),
        Text(value, style: AppTypography.listTitle.copyWith(fontSize: 13)),
      ],
    );
  }
}
