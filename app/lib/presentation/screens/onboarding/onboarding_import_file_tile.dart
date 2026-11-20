import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class OnboardingImportFileTile extends StatelessWidget {
  final File file;
  final ValueChanged<String> onSelected;

  const OnboardingImportFileTile({
    super.key,
    required this.file,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.canvasBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: const Icon(Icons.description_outlined, color: AppColors.neoChartreuse, size: 24),
        title: Text(fileName, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: const Text('Ketuk untuk pulihkan', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
        onTap: () {
          try {
            final content = file.readAsStringSync();
            onSelected(content);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal membaca file: $e'),
              backgroundColor: AppColors.statusDeficit,
            ));
          }
        },
      ),
    );
  }
}
