import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class BackupPasswordPromptModal extends StatefulWidget {
  final ValueChanged<String?> onConfirmed;
  const BackupPasswordPromptModal({super.key, required this.onConfirmed});

  static Future<void> show(BuildContext context, {required ValueChanged<String?> onConfirmed}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackupPasswordPromptModal(onConfirmed: onConfirmed),
    );
  }

  @override
  State<BackupPasswordPromptModal> createState() => _BackupPasswordPromptModalState();
}

class _BackupPasswordPromptModalState extends State<BackupPasswordPromptModal> {
  final _passwordCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(bool encrypt) {
    final pwd = encrypt ? _passwordCtrl.text.trim() : null;
    Navigator.pop(context);
    widget.onConfirmed(pwd);
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetScaffold(
      child: Padding(
        padding: EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: ModalGrabHandle()),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.enhanced_encryption_rounded, color: AppColors.neoChartreuse, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proteksi Cadangan (AES-256)', style: TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('Amankan data saldo & transaksi dari pencurian berkas', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscureText,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Kata Sandi / PIN Cadangan (Disarankan)',
                hintStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 13),
                filled: true,
                fillColor: AppColors.canvasBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted, size: 20),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dengan enkripsi AES-256, berkas cadangan terkunci rapat dan mustahil dibaca oleh pihak lain tanpa kata sandi ini.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 20),
            PrimaryActionButton(
              text: 'Simpan Terenkripsi (Aman)',
              icon: Icons.shield_rounded,
              onPressed: () {
                if (_passwordCtrl.text.trim().isNotEmpty) {
                  _submit(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Masukkan kata sandi/PIN, atau pilih opsi tanpa sandi di bawah.'),
                    backgroundColor: AppColors.statusCaution,
                  ));
                }
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _submit(false),
                child: const Text('Simpan Tanpa Sandi (JSON Polos)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
