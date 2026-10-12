import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../core/smart_input/smart_input_bridge.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'add_action_button.dart';
import 'transaction_modal.dart';

/// Morphing input menu: the dock '+' button rotates in-place into '×' while
/// 3 pill buttons morph directly upward out of the exact '+' button rect.
class QuickTransactionInputSheet extends StatefulWidget {
  final BuildContext hostContext;
  final Animation<double> animation;
  final Rect? anchorRect;

  const QuickTransactionInputSheet({super.key, required this.hostContext, required this.animation, this.anchorRect});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    final box = AddActionButton.buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final rect = (box != null && box.hasSize) ? (box.localToGlobal(Offset.zero) & box.size) : null;
    AddActionButton.isMenuOpen.value = true;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup opsi input',
      barrierColor: Colors.black.withValues(alpha: 0.58),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim, secAnim) => QuickTransactionInputSheet(hostContext: context, animation: anim, anchorRect: rect),
      transitionBuilder: (ctx, anim, secAnim, child) => child,
    ).whenComplete(() => AddActionButton.isMenuOpen.value = false);
  }

  @override
  State<QuickTransactionInputSheet> createState() => _QuickTransactionInputSheetState();
}

class _QuickTransactionInputSheetState extends State<QuickTransactionInputSheet> {
  bool _showPhotoSources = false;

  Future<void> _openMode(SmartInputSource? source) async {
    HapticFeedback.selectionClick();
    final hostCtx = widget.hostContext;
    Navigator.of(context).pop();
    if (source == null) { TransactionModal.show(hostCtx); return; }
    if (!hostCtx.mounted) return;
    final state = hostCtx.read<FinanceBloc>().state;
    final draft = await executeSmartTransactionCapture(hostCtx, source: source, wallets: state.wallets, categories: state.categories);
    if (!hostCtx.mounted || draft == null || !draft.hasMeaningfulData) return;
    TransactionModal.show(hostCtx, initialDraft: draft);
  }

  Widget _buildMorphPill({
    required int slotIndex,
    required double rawT,
    required double anchorRight,
    required double anchorBottom,
    required Key itemKey,
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final start = slotIndex * 0.06;
    final localT = ((rawT - start) / (1.0 - start)).clamp(0.0, 1.0);
    final morphT = Curves.easeOutCubic.transform(localT);
    final bottom = lerpDouble(anchorBottom, anchorBottom + 68.0 + (slotIndex * 56.0), morphT)!;
    final right = anchorRight;
    final width = lerpDouble(56.0, 176.0, morphT)!;
    final height = lerpDouble(56.0, 48.0, morphT)!;
    final bgColor = Color.lerp(AppColors.neoChartreuse, AppColors.canvasCardSurface, (morphT * 1.35).clamp(0.0, 1.0))!;
    final borderColor = Color.lerp(AppColors.neoChartreuse, accent.withValues(alpha: 0.55), morphT)!;
    final textAlpha = ((morphT - 0.25) / 0.75).clamp(0.0, 1.0);

    return Positioned(
      right: right,
      bottom: bottom,
      child: Opacity(
        opacity: (localT * 3.0).clamp(0.0, 1.0),
        child: GestureDetector(
          key: itemKey,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: width,
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.36 * morphT), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.8, right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Color.lerp(AppColors.textDarkPrimary, accent, morphT), size: 20),
                    const SizedBox(width: 11),
                    Opacity(
                      opacity: textAlpha,
                      child: Text(label, maxLines: 1, style: AppTypography.listTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.viewPaddingOf(context);
    final rect = widget.anchorRect;
    final anchorRight = rect != null ? (size.width - rect.right) : 20.0;
    final anchorBottom = rect != null ? (size.height - rect.bottom) : (12.0 + pad.bottom);

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, _) {
          final rawT = widget.animation.value;
          final rotT = Curves.easeOutCubic.transform(rawT);
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox.expand(),
                ),
              ),
              if (!_showPhotoSources) ...[
                _buildMorphPill(slotIndex: 0, rawT: rawT, anchorRight: anchorRight, anchorBottom: anchorBottom, itemKey: const Key('quick_input_manual_tile'), icon: Icons.edit_note_rounded, label: 'Input Manual', accent: AppColors.textWhite, onTap: () => _openMode(null)),
                _buildMorphPill(slotIndex: 1, rawT: rawT, anchorRight: anchorRight, anchorBottom: anchorBottom, itemKey: const Key('quick_input_voice_tile'), icon: Icons.mic_rounded, label: 'Voice', accent: AppColors.neoChartreuse, onTap: () => _openMode(SmartInputSource.voice)),
                _buildMorphPill(
                  slotIndex: 2, rawT: rawT, anchorRight: anchorRight, anchorBottom: anchorBottom, itemKey: const Key('quick_input_photo_tile'), icon: Icons.camera_alt_rounded, label: 'Foto', accent: AppColors.neoCyan,
                  onTap: () {
                    if (SmartInputBridge.testPhotoOcrOverride != null) { _openMode(SmartInputSource.camera); } else { HapticFeedback.selectionClick(); setState(() => _showPhotoSources = true); }
                  },
                ),
              ] else ...[
                _buildMorphPill(slotIndex: 0, rawT: rawT, anchorRight: anchorRight, anchorBottom: anchorBottom, itemKey: const Key('quick_input_gallery_tile'), icon: Icons.photo_library_rounded, label: 'Galeri (Transfer)', accent: AppColors.neoMint, onTap: () => _openMode(SmartInputSource.gallery)),
                _buildMorphPill(slotIndex: 1, rawT: rawT, anchorRight: anchorRight, anchorBottom: anchorBottom, itemKey: const Key('quick_input_camera_tile'), icon: Icons.photo_camera_rounded, label: 'Kamera (Struk)', accent: AppColors.neoCyan, onTap: () => _openMode(SmartInputSource.camera)),
              ],
              Positioned(
                right: anchorRight,
                bottom: anchorBottom,
                child: GestureDetector(
                  key: const Key('quick_input_close_fab'),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 56, height: 56,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.neoChartreuse),
                    child: Transform.rotate(
                      angle: rotT * 0.785398,
                      child: const Icon(Icons.add_rounded, color: AppColors.textDarkPrimary, size: 30),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
