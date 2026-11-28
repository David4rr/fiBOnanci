import 'package:flutter/material.dart';

import '../../core/l10n/locale_notifier.dart';
import '../../core/storage/kofi_prompt_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/common_widgets.dart';
import 'kofi_webview_modal.dart';

enum _KofiAction { support, handled }

class KofiSupportModal extends StatelessWidget {
  const KofiSupportModal({super.key});

  static Future<void> show(BuildContext context) async {
    final action = await showModalBottomSheet<_KofiAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const KofiSupportModal(
        key: Key('kofi_support_modal'),
      ),
    );
    if (action == null) {
      await KofiPromptStorage.snooze();
    } else if (action == _KofiAction.support && context.mounted) {
      await KofiWebViewModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return ModalSheetScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: ModalGrabHandle()),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.neoCoral.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.neoCoral.withValues(alpha: 0.35),
                  ),
                ),
                child: Image.asset(
                  'assets/images/dev_avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.local_cafe_rounded,
                    color: AppColors.neoCoral,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.kofiPromptTitle,
                  style: AppTypography.sectionTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.kofiPromptBody,
            style: AppTypography.listSubtitle.copyWith(
              color: AppColors.textMuted,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          KofiSupportButton(
            key: const Key('kofi_support_btn'),
            label: l10n.kofiPromptSupportBtn,
            onTap: () async {
              await KofiPromptStorage.markSupportedOrDismissed();
              if (context.mounted) Navigator.of(context).pop(_KofiAction.support);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  key: const Key('kofi_later_btn'),
                  onPressed: () async {
                    await KofiPromptStorage.snooze();
                    if (context.mounted) Navigator.of(context).pop(_KofiAction.handled);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.kofiPromptLaterBtn,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  key: const Key('kofi_never_btn'),
                  onPressed: () async {
                    await KofiPromptStorage.markSupportedOrDismissed();
                    if (context.mounted) Navigator.of(context).pop(_KofiAction.handled);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted.withValues(alpha: 0.75),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.kofiPromptNeverBtn,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
