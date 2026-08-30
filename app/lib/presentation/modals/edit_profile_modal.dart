import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../core/formatters/rupiah_input_formatter.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/profile_avatar.dart';

class EditProfileModal extends StatefulWidget {
  final ProfileEntry? initialProfile;

  const EditProfileModal({
    super.key,
    this.initialProfile,
  });

  static Future<void> show(BuildContext context, {ProfileEntry? profile}) {
    final bloc = context.read<FinanceBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
  bool _setActive = true;
  bool _isPickingImage = false;
  bool get isEditing => widget.initialProfile != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _selectedAvatar = (p?.avatarPath != null && !p!.avatarPath!.startsWith('preset:') && p.avatarPath!.isNotEmpty)
        ? p.avatarPath
        : null;
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
  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        final appDir = await getApplicationDocumentsDirectory();
        final ext = p.extension(pickedFile.path).isNotEmpty ? p.extension(pickedFile.path) : '.jpg';
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
        final savedFile = File('${appDir.path}/$fileName');
        await File(pickedFile.path).copy(savedFile.path);

        setState(() {
          _selectedAvatar = savedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat memilih gambar: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showImageSourceDialog() {
    final hasPhoto = _selectedAvatar != null && _selectedAvatar!.isNotEmpty;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17181F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Sumber Foto',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.neoChartreuse, size: 20),
                ),
                title: Text(
                  'Galeri Foto',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Pilih gambar dari galeri atau album foto perangkat',
                  style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(color: AppColors.canvasBorder, height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neoCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.neoCyan, size: 20),
                ),
                title: Text(
                  'Kamera',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Ambil foto baru langsung menggunakan kamera',
                  style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (hasPhoto) ...[
                const Divider(color: AppColors.canvasBorder, height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                  ),
                  title: Text(
                    'Hapus Foto Profil',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'Gunakan inisial nama sebagai avatar',
                    style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _selectedAvatar = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        avatarPath: _selectedAvatar,
        occupation: occupation,
        bio: bio,
        currency: _selectedCurrency,
        monthlyIncomeTarget: monthlyIncomeTarget,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil $username berhasil diperbarui!'),
          backgroundColor: AppColors.neoMint,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      bloc.add(AddProfileEvent(
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        avatarPath: _selectedAvatar,
        occupation: occupation,
        bio: bio,
        currency: _selectedCurrency,
        monthlyIncomeTarget: monthlyIncomeTarget,
        setActive: _setActive,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil $username berhasil dibuat!'),
          backgroundColor: AppColors.neoMint,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle & Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit Profil' : 'Tambah Profil Baru',
                          style: AppTypography.heroGreeting.copyWith(fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.canvasBorder, height: 16),

            // Scrollable Form Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // 1. Avatar Selection
                  _buildAvatarSection(),
                  const SizedBox(height: 24),

                  // 2. Primary Identification
                  _buildSectionHeader('INFORMASI UTAMA'),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _usernameController,
                    label: 'Username',
                    hintText: 'e.g. David',
                    prefixIcon: Icons.alternate_email_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Username wajib diisi';
                      }
                      if (val.trim().length < 2) {
                        return 'Username minimal 2 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _fullNameController,
                    label: 'Nama Lengkap',
                    hintText: 'e.g. David Arrozaqi',
                    prefixIcon: Icons.badge_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama lengkap wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. Contact Info
                  _buildSectionHeader('KONTAK & KOMUNIKASI'),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'e.g. david@fibonanci.app',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'No. Handphone / WhatsApp',
                    hintText: 'e.g. +62 812-3456-7890',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // 4. Professional & Bio
                  _buildSectionHeader('PROFESI & CATATAN'),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _occupationController,
                    label: 'Profesi / Pekerjaan',
                    hintText: 'e.g. Software Engineer, Designer, Freelancer',
                    prefixIcon: Icons.work_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _bioController,
                    label: 'Bio / Catatan Pribadi',
                    hintText: 'e.g. Membangun kebebasan finansial offline',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // 5. Financial Preferences
                  _buildSectionHeader('PENGATURAN FINANSIAL'),
                  const SizedBox(height: 10),
                  _buildCurrencySelector(),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _incomeTargetController,
                    label: 'Target Pemasukan Bulanan',
                    hintText: 'Rp 15.000.000',
                    prefixIcon: Icons.savings_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                  ),

                  if (!isEditing) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jadikan Profil Aktif',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Gunakan akun ini saat membuka aplikasi',
                                  style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _setActive,
                            onChanged: (val) => setState(() => _setActive = val),
                            activeThumbColor: AppColors.neoChartreuse,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Save Button
                  GestureDetector(
                    onTap: _onSave,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: AppColors.neoChartreuse,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neoChartreuse.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Buat Profil Baru',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textDarkPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.badgeLabel.copyWith(
        color: AppColors.neoChartreuse,
        fontSize: 11,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildAvatarSection() {
    final hasPhoto = _selectedAvatar != null && _selectedAvatar!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showImageSourceDialog,
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ProfileAvatar(
                  avatarPath: _selectedAvatar,
                  name: _usernameController.text.isNotEmpty ? _usernameController.text : 'FI',
                  size: 64,
                  iconSize: 32,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neoChartreuse,
                      border: Border.all(color: const Color(0xFF17181F), width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 11,
                      color: AppColors.textDarkPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto Profil',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasPhoto
                        ? 'Foto kustom aktif • Ketuk untuk ganti'
                        : 'Ketuk untuk pilih dari galeri atau kamera',
                    style: AppTypography.listSubtitle.copyWith(
                      fontSize: 11.5,
                      color: hasPhoto ? AppColors.neoMint : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSubtle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<dynamic>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: inputFormatters != null ? List.from(inputFormatters) : null,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 13),
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 18),
            filled: true,
            fillColor: AppColors.canvasInputSearch,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.canvasBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.canvasBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.neoChartreuse, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    const currencies = ['IDR', 'USD', 'EUR', 'SGD'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mata Uang Utama',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: currencies.map((c) {
            final isSelected = _selectedCurrency == c;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCurrency = c),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.neoChartreuse : AppColors.canvasInputSearch,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      c,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
