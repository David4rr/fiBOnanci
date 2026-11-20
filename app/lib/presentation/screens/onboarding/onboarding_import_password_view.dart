import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class OnboardingImportPasswordView extends StatefulWidget {
  final ValueChanged<String> onPasswordSubmitted;
  final VoidCallback onCancel;
  final String? errorMessage;

  const OnboardingImportPasswordView({
    super.key,
    required this.onPasswordSubmitted,
    required this.onCancel,
    this.errorMessage,
  });

  @override
  State<OnboardingImportPasswordView> createState() => _OnboardingImportPasswordViewState();
}

class _OnboardingImportPasswordViewState extends State<OnboardingImportPasswordView> {
  final _passwordCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final pwd = _passwordCtrl.text.trim();
    if (pwd.isNotEmpty) {
      widget.onPasswordSubmitted(pwd);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              child: const Icon(Icons.lock_rounded, color: AppColors.neoChartreuse, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cadangan Terenkripsi (AES-256)', style: TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Masukkan kata sandi atau PIN untuk membuka', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.statusDeficit.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.statusDeficit.withValues(alpha: 0.4)),
            ),
            child: Text(widget.errorMessage!, style: const TextStyle(color: AppColors.statusDeficit, fontSize: 12)),
          ),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscureText,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Kata Sandi / PIN Cadangan',
            hintStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 13),
            filled: true,
            fillColor: AppColors.canvasBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.key_rounded, color: AppColors.textMuted, size: 18),
            suffixIcon: IconButton(
              icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted, size: 20),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        PrimaryActionButton(
          text: 'Buka Kunci & Pulihkan',
          icon: Icons.lock_open_rounded,
          onPressed: _submit,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: widget.onCancel,
            child: const Text('Batal & Pilih Berkas Lain', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
