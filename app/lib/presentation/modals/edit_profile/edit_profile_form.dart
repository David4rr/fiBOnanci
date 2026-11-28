import 'package:flutter/material.dart';
import '../../../core/l10n/locale_notifier.dart';
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
            title: isEditing ? AppL10n.of(context).editProfileTitle : AppL10n.of(context).newProfileTitle,
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
  final List<String>? existingUsernames;

  const EditProfileForm({
    super.key,
    required this.usernameController,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.occupationController,
    required this.bioController,
    this.existingUsernames,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditProfileInputField(
          controller: usernameController,
          label: 'Username / Handle',
          hintText: 'e.g. alexander',
          prefixIcon: Icons.alternate_email_rounded,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Username wajib diisi';
            final clean = val.trim().replaceAll('@', '');
            if (clean.length < 2) return 'Username minimal 2 karakter';
            if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(clean)) {
              return 'Hanya huruf, angka, titik, dan garis bawah (_)';
            }
            if (existingUsernames != null &&
                existingUsernames!.any((u) => u.toLowerCase() == clean.toLowerCase())) {
              return 'Username @$clean sudah digunakan';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: fullNameController,
          label: l10n.editProfileFullName,
          hintText: 'e.g. Alexander William',
          prefixIcon: Icons.badge_outlined,
          validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: emailController,
          label: 'Email',
          hintText: l10n.editProfileEmailHint,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: phoneController,
          label: l10n.editProfilePhone,
          hintText: 'e.g. +62 812-xxxx-xxxx',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: occupationController,
          label: l10n.editProfileOccupation,
          hintText: l10n.editProfileOccHint,
          prefixIcon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: 12),
        EditProfileInputField(
          controller: bioController,
          label: l10n.editProfileBio,
          hintText: l10n.editProfileBioHint,
          prefixIcon: Icons.notes_rounded,
          maxLines: 2,
        ),
      ],
    );
  }
}
