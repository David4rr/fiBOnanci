import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import 'edit_profile/edit_profile_avatar_picker.dart';
import 'edit_profile/edit_profile_form.dart';

export 'edit_profile/edit_profile_avatar_picker.dart';
export 'edit_profile/edit_profile_form.dart';

class EditProfileModal extends StatefulWidget {
  final ProfileEntry? initialProfile;
  const EditProfileModal({super.key, this.initialProfile});

  static Future<void> show(BuildContext context, {ProfileEntry? profile}) {
    final bloc = context.read<FinanceBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: EditProfileModal(initialProfile: profile),
        ),
      ),
    );
  }

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _occupationController;
  late TextEditingController _bioController;
  late TextEditingController _incomeTargetController;

  String? _selectedAvatar;
  late String _selectedCurrency;
  final bool _setActive = true;
  bool get isEditing => widget.initialProfile != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _selectedAvatar = (p?.avatarPath != null && !p!.avatarPath!.startsWith('preset:') && p.avatarPath!.isNotEmpty) ? p.avatarPath : null;
    _selectedCurrency = p?.currency ?? 'IDR';

    _usernameController = TextEditingController(text: p?.username ?? '');
    _fullNameController = TextEditingController(text: p?.fullName ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _occupationController = TextEditingController(text: p?.occupation ?? '');
    _bioController = TextEditingController(text: p?.bio ?? '');

    final target = p?.monthlyIncomeTarget;
    _incomeTargetController = TextEditingController(
      text: target != null && target > 0 ? RupiahInputFormatter.format(target) : '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _bioController.dispose();
    _incomeTargetController.dispose();
    super.dispose();
  }

  void _onPickSource(ImageSource source) async {
    final path = await EditProfileAvatarPicker.pickImage(context, source);
    if (path != null && mounted) setState(() => _selectedAvatar = path);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final occupation = _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim();
    final bio = _bioController.text.trim().isEmpty ? null : _bioController.text.trim();
    final rawIncome = RupiahInputFormatter.parse(_incomeTargetController.text.trim());
    final monthlyIncomeTarget = rawIncome > 0 ? rawIncome : null;

    final bloc = context.read<FinanceBloc>();
    if (isEditing) {
      bloc.add(UpdateProfileEvent(
        profileId: widget.initialProfile!.id,
        username: username, fullName: fullName, email: email, phone: phone,
        avatarPath: _selectedAvatar, occupation: occupation, bio: bio,
        currency: _selectedCurrency, monthlyIncomeTarget: monthlyIncomeTarget,
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil $username berhasil diperbarui!'), backgroundColor: AppColors.neoMint, behavior: SnackBarBehavior.floating));
    } else {
      bloc.add(AddProfileEvent(
        username: username, fullName: fullName, email: email, phone: phone,
        avatarPath: _selectedAvatar, occupation: occupation, bio: bio,
        currency: _selectedCurrency, monthlyIncomeTarget: monthlyIncomeTarget, setActive: _setActive,
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil $username berhasil dibuat!'), backgroundColor: AppColors.neoChartreuse, behavior: SnackBarBehavior.floating));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditProfileHeader(isEditing: isEditing),
            const Divider(color: AppColors.canvasBorder, height: 16),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditProfileAvatarPicker.buildPickerWidget(
                      context: context,
                      avatarPath: _selectedAvatar,
                      name: _usernameController.text,
                      onTap: () => EditProfileAvatarPicker.showSourceDialog(
                        context: context,
                        hasPhoto: _selectedAvatar != null && _selectedAvatar!.isNotEmpty,
                        onSelectSource: _onPickSource,
                        onRemovePhoto: () => setState(() => _selectedAvatar = null),
                      ),
                    ),
                    const SizedBox(height: 24),
                    EditProfileForm(
                      usernameController: _usernameController,
                      fullNameController: _fullNameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      occupationController: _occupationController,
                      bioController: _bioController,
                      incomeTargetController: _incomeTargetController,
                      selectedCurrency: _selectedCurrency,
                      onCurrencyChanged: (c) => setState(() => _selectedCurrency = c),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neoChartreuse,
                          foregroundColor: AppColors.textDarkPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _onSave,
                        child: Text(isEditing ? 'Simpan Perubahan' : 'Buat Profil Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
