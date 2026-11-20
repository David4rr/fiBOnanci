import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/security/backup_cipher.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'backup_export_completed_view.dart';
import 'settings_backup_helper.dart';

class BackupExportModal extends StatefulWidget {
  final FinanceState state;
  final String? password;

  const BackupExportModal({super.key, required this.state, this.password});

  static Future<void> show(BuildContext context, {required FinanceState state, String? password}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackupExportModal(state: state, password: password),
    );
  }

  @override
  State<BackupExportModal> createState() => _BackupExportModalState();
}

class _BackupExportModalState extends State<BackupExportModal> {
  int _step = 1;
  bool _isComplete = false;
  String? _savedPath;
  String? _jsonPayload;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startExport();
  }

  Future<void> _startExport() async {
    final s = widget.state;
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    final stepDelay = isTest ? const Duration(milliseconds: 10) : const Duration(milliseconds: 320);

    try {
      await Future.delayed(stepDelay);
      if (!mounted) return;

      final payload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': {'id': s.profile.id, 'username': s.profile.username, 'currency': s.profile.currency},
        'walletsCount': s.wallets.length,
        'pocketsCount': s.pockets.length,
        'subscriptionsCount': s.subscriptions.length,
        'transactionsCount': s.transactions.length,
        'profiles': s.profiles.map((e) => e.toJson()).toList(),
        'categories': s.categories.map((e) => e.toJson()).toList(),
        'wallets': s.wallets.map((e) => e.toJson()).toList(),
        'pockets': s.pockets.map((e) => e.toJson()).toList(),
        'subscriptions': s.subscriptions.map((e) => e.toJson()).toList(),
        'transactions': s.transactions.map((e) => e.toJson()).toList(),
      };

      setState(() => _step = 2);
      await Future.delayed(stepDelay);
      if (!mounted) return;

      final Map<String, dynamic> finalPayload;
      if (widget.password != null && widget.password!.isNotEmpty) {
        finalPayload = BackupCipher.encrypt(payload, widget.password!);
      } else {
        finalPayload = payload;
      }

      final jsonStr = const JsonEncoder.withIndent('  ').convert(finalPayload);
      _jsonPayload = jsonStr;
      try {
        await Clipboard.setData(ClipboardData(text: jsonStr));
      } catch (_) {}

      setState(() => _step = 3);
      await Future.delayed(stepDelay);
      if (!mounted) return;

      final path = await SettingsBackupHelper.saveExportFile(
        'fibonanci_backup_${s.profile.username}.json',
        jsonStr,
      );

      if (mounted) {
        setState(() {
          _savedPath = path;
          _isComplete = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Gagal menyimpan cadangan: $e');
    }
  }

  Widget _buildStepItem(int stepNumber, String title, String subtitle) {
    final bool isDone = _step > stepNumber || _isComplete;
    final bool isCurrent = _step == stepNumber && !_isComplete;
    final Color iconColor = isDone ? AppColors.neoMint : (isCurrent ? AppColors.neoChartreuse : AppColors.textSubtle);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded, color: AppColors.neoMint, size: 15)
                  : (isCurrent
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neoChartreuse))
                      : Text('$stepNumber', style: const TextStyle(color: AppColors.textSubtle, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: isDone || isCurrent ? AppColors.textWhite : AppColors.textMuted, fontSize: 13, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600)),
              Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final isEnc = widget.password != null && widget.password!.isNotEmpty;

    return ModalSheetScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: ModalGrabHandle()),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              const Icon(Icons.error_outline_rounded, color: AppColors.neoCoral, size: 40),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.neoCoral, fontSize: 12)),
              const SizedBox(height: 16),
              PrimaryActionButton(text: 'Tutup', onPressed: () => Navigator.pop(context)),
            ] else if (!_isComplete) ...[
              ModalHeader(
                title: isEnc ? 'Menyimpan Cadangan Terenkripsi' : 'Menyimpan Cadangan JSON',
                subtitle: isEnc ? 'Mengunci data dengan enkripsi AES-256...' : 'Memproses seluruh data keuangan ke berkas offline.',
              ),
              const SizedBox(height: 14),
              _buildStepItem(1, 'Mengumpulkan Data Akun', '${s.wallets.length} Rekening • ${s.transactions.length} Transaksi • ${s.subscriptions.length} Tagihan'),
              _buildStepItem(2, isEnc ? 'Mengenkripsi AES-256' : 'Mengemas & Menyalin Teks', isEnc ? 'Mengunci payload dengan salt & HMAC-SHA256' : 'Membuat payload JSON & menyalin ke clipboard'),
              _buildStepItem(3, 'Menulis Berkas Penyimpanan', 'Menyimpan berkas di folder Download perangkat'),
            ] else ...[
              BackupExportCompletedView(state: s, savedPath: _savedPath ?? '-', jsonPayload: _jsonPayload, isEncrypted: isEnc),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
