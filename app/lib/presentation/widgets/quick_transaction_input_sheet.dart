import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../core/smart_input/smart_input_bridge.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';
import 'transaction_modal.dart';

/// Morphing Speed-Dial FAB: the '+' dock button rotates into '×' while
/// 3 separate unified pill buttons morph upward out of the '+' button.
class QuickTransactionInputSheet extends StatefulWidget {
  final BuildContext hostContext;
  final Animation<double> animation;

  const QuickTransactionInputSheet({super.key, required this.hostContext, required this.animation});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup opsi input',
      barrierColor: Colors.black.withValues(alpha: 0.58),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim, secAnim) => QuickTransactionInputSheet(hostContext: context, animation: anim),
      transitionBuilder: (ctx, anim, secAnim, child) => child,
    );
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
    if (source == null) {
      TransactionModal.show(hostCtx);
      return;
    }
    if (!hostCtx.mounted) return;
    final state = hostCtx.read<FinanceBloc>().state;
    final draft = await executeSmartTransactionCapture(
      hostCtx,
      source: source,
      wallets: state.wallets,
      categories: state.categories,
    );
    if (!hostCtx.mounted || draft == null || !draft.hasMeaningfulData) return;
    TransactionModal.show(hostCtx, initialDraft: draft);
  }

  Widget _buildMorphPill({
    required int slotIndex,
    required double rawT,
    required Key itemKey,
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final start = slotIndex * 0.07;
    final localT = ((rawT - start) / (1.0 - start)).clamp(0.0, 1.0);
    final riseT = Curves.easeOutQuart.transform((localT / 0.62).clamp(0.0, 1.0));
    final expandT = Curves.easeOutQuart.transform(((localT - 0.26) / 0.74).clamp(0.0, 1.0));
    final bottom = lerpDouble(16.0, 82.0 + (slotIndex * 58.0), riseT)!;
    final right = lerpDouble(24.0, 20.0, riseT)!;
    final width = lerpDouble(48.0, 176.0, expandT)!;
    final bgColor = Color.lerp(AppColors.neoChartreuse, AppColors.canvasCardSurface, (riseT * 1.25).clamp(0.0, 1.0))!;
    final borderColor = Color.lerp(AppColors.neoChartreuse, accent.withValues(alpha: 0.55), expandT)!;
    final textAlpha = ((expandT - 0.18) / 0.82).clamp(0.0, 1.0);

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
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.36 * riseT), blurRadius: 14, offset: const Offset(0, 6)),
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
                    Icon(icon, color: Color.lerp(AppColors.textDarkPrimary, accent, riseT), size: 20),
                    const SizedBox(width: 11),
                    Opacity(
                      opacity: textAlpha,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: AppTypography.listTitle.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
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
    return IPhoneViewportContainer(
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: widget.animation,
            builder: (context, _) {
              final rawT = widget.animation.value;
              final rotT = Curves.easeOutQuart.transform(rawT);
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
                    _buildMorphPill(slotIndex: 0, rawT: rawT, itemKey: const Key('quick_input_manual_tile'), icon: Icons.edit_note_rounded, label: 'Input Manual', accent: AppColors.textWhite, onTap: () => _openMode(null)),
                    _buildMorphPill(slotIndex: 1, rawT: rawT, itemKey: const Key('quick_input_voice_tile'), icon: Icons.mic_rounded, label: 'Voice', accent: AppColors.neoChartreuse, onTap: () => _openMode(SmartInputSource.voice)),
                    _buildMorphPill(
                      slotIndex: 2, rawT: rawT, itemKey: const Key('quick_input_photo_tile'), icon: Icons.camera_alt_rounded, label: 'Foto', accent: AppColors.neoCyan,
                      onTap: () {
                        if (SmartInputBridge.testPhotoOcrOverride != null) { _openMode(SmartInputSource.camera); } else { HapticFeedback.selectionClick(); setState(() => _showPhotoSources = true); }
                      },
                    ),
                  ] else ...[
                    _buildMorphPill(slotIndex: 0, rawT: rawT, itemKey: const Key('quick_input_gallery_tile'), icon: Icons.photo_library_rounded, label: 'Galeri (Transfer)', accent: AppColors.neoMint, onTap: () => _openMode(SmartInputSource.gallery)),
                    _buildMorphPill(slotIndex: 1, rawT: rawT, itemKey: const Key('quick_input_camera_tile'), icon: Icons.photo_camera_rounded, label: 'Kamera (Struk)', accent: AppColors.neoCyan, onTap: () => _openMode(SmartInputSource.camera)),
                  ],
                  Positioned(
                    right: 20,
                    bottom: 12,
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
        ),
      ),
    );
  }
}
