import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import 'category_color_picker.dart';
import 'settings_budget_cycle_section.dart';

class SettingsCategorySection extends StatefulWidget {
  final List<CategoryEntry> categories;

  const SettingsCategorySection({super.key, required this.categories});

  @override
  State<SettingsCategorySection> createState() => _SettingsCategorySectionState();
}

class _SettingsCategorySectionState extends State<SettingsCategorySection> {
  String _selectedType = 'expense';
  bool _isAdding = false;
  String _selectedColor = CategoryColorPicker.palette.first;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final val = int.tryParse('FF$cleaned', radix: 16);
    return val != null ? Color(val) : AppColors.neoChartreuse;
  }

  void _submitCategory() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    context.read<FinanceBloc>().add(AddCategoryEvent(
      name: name,
      type: _selectedType,
      colorHex: _selectedColor,
    ));
    _nameCtrl.clear();
    setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    final allActive = widget.categories.where((c) => !c.isDeleted).toList();
    final filtered = allActive.where((c) => c.type == _selectedType).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              SettingsStyle.flatChip(
                key: const Key('settings_cat_type_expense'), label: 'Pengeluaran',
                selected: _selectedType == 'expense',
                onTap: () => setState(() => _selectedType = 'expense'),
              ),
              const SizedBox(width: 8),
              SettingsStyle.flatChip(
                key: const Key('settings_cat_type_income'), label: 'Pemasukan',
                selected: _selectedType == 'income',
                onTap: () => setState(() => _selectedType = 'income'),
              ),
            ]),
            GestureDetector(
              key: const Key('settings_add_category_toggle'), behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _isAdding = !_isAdding),
              child: Text(_isAdding ? 'Batal' : '+ Tambah', style: SettingsStyle.accent),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isAdding) ...[
          Row(children: [
            Expanded(
              child: TextField(
                key: const Key('settings_new_category_input'), controller: _nameCtrl, style: SettingsStyle.title,
                decoration: InputDecoration(
                  hintText: 'Nama kategori baru...', hintStyle: SettingsStyle.sub, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neoChartreuse)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(key: const Key('settings_save_category_button'), onTap: _submitCategory, child: Text('Simpan', style: SettingsStyle.accent)),
          ]),
          const SizedBox(height: 12),
          CategoryColorPicker(
            selectedColor: _selectedColor,
            onColorChanged: (c) => setState(() => _selectedColor = c),
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 6, runSpacing: 6,
          children: filtered.map((cat) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _parseColor(cat.colorHex))),
              const SizedBox(width: 7),
              Text(cat.name, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85))),
              if (filtered.length > 1) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  key: Key('settings_delete_cat_${cat.id}'), behavior: HitTestBehavior.opaque,
                  onTap: () => context.read<FinanceBloc>().add(DeleteCategoryEvent(cat.id)),
                  child: const Icon(Icons.close_rounded, size: 13, color: Colors.white38),
                ),
              ],
            ]),
          )).toList(),
        ),
      ],
    );
  }
}
