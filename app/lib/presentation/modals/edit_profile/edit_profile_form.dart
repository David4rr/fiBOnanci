import 'package:flutter/material.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import 'edit_profile_input_field.dart';

class EditProfileHeader extends StatelessWidget {
  final bool isEditing;

  const EditProfileHeader({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          const ModalGrabHandle(),
          ModalHeader(
            title: isEditing ? 'Edit Profil' : 'Tambah Profil Baru',
            titleStyle: AppTypography.heroGreeting.copyWith(fontSize: 20),
            closeIconColor: AppColors.textMuted,
            closeIconSize: 20,
            padding: EdgeInsets.zero,
            onClose: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class EditProfileForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController occupationController;
  final TextEditingController bioController;
  final TextEditingController incomeTargetController;
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;

  const EditProfileForm({
    super.key,
    required this.usernameController,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.occupationController,
    required this.bioController,
    required this.incomeTargetController,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditProfileInputField(
          controller: usernameController,
          label: 'Username',
          hintText: 'e.g. David',
          prefixIcon: Icons.alternate_email_rounded,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Username wajib diisi';
            if (val.trim().length < 2) return 'Username minimal 2 karakter';
            return null;
          },
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: fullNameController,
          label: 'Nama Lengkap',
          hintText: 'e.g. David Arrozaqi',
          prefixIcon: Icons.badge_outlined,
          validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: emailController,
          label: 'Email',
          hintText: 'e.g. david@fibonanci.app',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: phoneController,
          label: 'No. Handphone / WhatsApp',
          hintText: 'e.g. +62 812-3456-7890',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: occupationController,
          label: 'Profesi / Pekerjaan',
          hintText: 'e.g. Software Engineer',
          prefixIcon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: bioController,
          label: 'Bio / Catatan Pribadi',
          hintText: 'e.g. Membangun kebebasan finansial',
          prefixIcon: Icons.notes_rounded,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        EditProfileCurrencySelector(
          selectedCurrency: selectedCurrency,
          onCurrencyChanged: onCurrencyChanged,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: incomeTargetController,
          label: 'Target Pemasukan Bulanan',
          hintText: 'Rp 15.000.000',
          prefixIcon: Icons.savings_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [RupiahInputFormatter()],
        ),
      ],
    );
  }
}
