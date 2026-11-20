import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'onboarding_import_file_tile.dart';

class OnboardingImportFormView extends StatelessWidget {
  final List<File> foundFiles;
  final bool isSearching;
  final String? errorMessage;
  final VoidCallback onPickFile;
  final ValueChanged<String> onFileSelected;

  const OnboardingImportFormView({
    super.key,
    required this.foundFiles,
    required this.isSearching,
    this.errorMessage,
    required this.onPickFile,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: ModalGrabHandle()),
        const SizedBox(height: 16),
        const ModalHeader(
          title: 'Pulihkan Data (.JSON)',
          subtitle: 'Pilih berkas cadangan dari memori atau folder Download.',
        ),
        const SizedBox(height: 14),
        if (errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.statusDeficit.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.statusDeficit.withValues(alpha: 0.4)),
            ),
            child: Text(errorMessage!, style: const TextStyle(color: AppColors.statusDeficit, fontSize: 12)),
          ),
        PrimaryActionButton(
          key: const Key('pick_json_file_btn'),
          text: 'Pilih Berkas .JSON',
          icon: Icons.folder_open_rounded,
          onPressed: onPickFile,
        ),
        const SizedBox(height: 20),
        if (isSearching)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (foundFiles.isNotEmpty) ...[
          const Text(
            'Berkas cadangan terdeteksi di perangkat:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...foundFiles.map((f) => OnboardingImportFileTile(file: f, onSelected: onFileSelected)),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.canvasCardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Belum ada berkas cadangan otomatis di folder Download. Gunakan tombol "Pilih Berkas .JSON" di atas untuk mencari berkas di perangkat Anda.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
