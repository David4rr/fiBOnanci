import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

bool get _isFlutterTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

class OnboardingLanguageStep extends StatelessWidget {
  final VoidCallback onContinue;
  const OnboardingLanguageStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (ctx, locale, _) {
        final l10n = AppL10n.of(ctx);
        final isId = locale.languageCode == 'id';
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 164,
              width: 200,
              child: Lottie.asset(
                'assets/lottie/onb_language.json',
                height: 164,
                animate: !_isFlutterTest,
                repeat: true,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.translate_rounded,
                  color: AppColors.neoChartreuse,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.onbLangTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onbLangSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 24),
            _langCard(
              key: const Key('onb_lang_id_btn'),
              badge: 'ID',
              title: l10n.onbLangIdTitle,
              subtitle: l10n.onbLangIdSub,
              selected: isId,
              onTap: () => setAppLocale(const Locale('id')),
            ),
            const SizedBox(height: 12),
            _langCard(
              key: const Key('onb_lang_en_btn'),
              badge: 'EN',
              title: l10n.onbLangEnTitle,
              subtitle: l10n.onbLangEnSub,
              selected: !isId,
              onTap: () => setAppLocale(const Locale('en')),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              key: const Key('onb_lang_continue_btn'),
              text: l10n.onbContinue,
              icon: Icons.arrow_forward_rounded,
              onPressed: onContinue,
            ),
          ],
        );
      },
    );
  }

  Widget _langCard({
    required Key key,
    required String badge,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final border = selected ? AppColors.neoChartreuse.withValues(alpha: 0.6) : AppColors.canvasBorder;
    final bg = selected ? AppColors.neoChartreuse.withValues(alpha: 0.12) : AppColors.canvasCardSurface;
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.neoChartreuse : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: selected ? AppColors.textDarkPrimary : AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textWhite, fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.neoChartreuse : AppColors.textMuted.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
