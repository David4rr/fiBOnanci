import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/l10n/category_localizer.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/category_icon_resolver.dart';
import '../../widgets/common/common_widgets.dart';
import 'category_capsule_timeline.dart';
import 'category_color_picker.dart';
import 'category_icon_picker.dart';
import 'settings_budget_cycle_section.dart';

class SettingsCategorySection extends StatefulWidget {
  final List<CategoryEntry> categories;

  const SettingsCategorySection({super.key, required this.categories});

  @override
  State<SettingsCategorySection> createState() => _SettingsCategorySectionState();
}

class _SettingsCategorySectionState extends State<SettingsCategorySection> {
  String _selectedType = 'expense';
  bool _isFormOpen = false;
  CategoryEntry? _editingCategory;
  String _selectedColor = CategoryColorPicker.palette.first;
  String _selectedIcon = 'category';
  String? _selectedCategoryId;
  String? _pendingSelectName;
  final _nameCtrl = TextEditingController();

  @override
  void didUpdateWidget(covariant SettingsCategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pendingSelectName != null && widget.categories.length > oldWidget.categories.length) {
      final match = widget.categories.where((c) => !c.isDeleted && c.name == _pendingSelectName).lastOrNull;
      if (match != null) {
        _selectedCategoryId = match.id;
        _pendingSelectName = null;
      }
    }
  }

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

  void _openAdd() => setState(() {
        _isFormOpen = !_isFormOpen || _editingCategory != null;
        _editingCategory = null;
        if (_isFormOpen) {
          _nameCtrl.clear();
          _selectedColor = CategoryColorPicker.palette.first;
          _selectedIcon = 'category';
        }
      });

  void _openEdit(CategoryEntry cat) => setState(() {
        _editingCategory = cat;
        _isFormOpen = true;
        _nameCtrl.text = cat.name;
        _selectedColor = cat.colorHex;
        _selectedIcon = cat.iconName;
      });

  void _submitCategory() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final bloc = context.read<FinanceBloc>();
    if (_editingCategory != null) {
      bloc.add(UpdateCategoryEvent(
        categoryId: _editingCategory!.id,
        name: name,
        colorHex: _selectedColor,
        iconName: _selectedIcon,
      ));
      _selectedCategoryId = _editingCategory!.id;
    } else {
      bloc.add(AddCategoryEvent(
        name: name,
        type: _selectedType,
        colorHex: _selectedColor,
        iconName: _selectedIcon,
      ));
      _pendingSelectName = name;
    }
    _nameCtrl.clear();
    setState(() {
      _isFormOpen = false;
      _editingCategory = null;
      _selectedIcon = 'category';
    });
  }

  Future<void> _confirmDelete(BuildContext context, CategoryEntry cat) async {
    final l10n = AppL10n.of(context);
    final catName = CategoryLocalizer.entry(context, cat);
    final ok = await AppConfirmationDialog.show(
      context,
      title: l10n.catDeleteConfirmTitle,
      content: l10n.catDeleteConfirmBody(catName),
      confirmText: l10n.txDeleteConfirm,
    );
    if (ok == true && context.mounted) {
      context.read<FinanceBloc>().add(DeleteCategoryEvent(cat.id));
      if (_selectedCategoryId == cat.id) setState(() => _selectedCategoryId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final allActive = widget.categories.where((c) => !c.isDeleted).toList();
    final filtered = allActive.where((c) => c.type == _selectedType).toList();
    final previewColor = _parseColor(_selectedColor);
    final isDarkIcon = ThemeData.estimateBrightnessForColor(previewColor) == Brightness.light;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              SettingsStyle.flatChip(
                key: const Key('settings_cat_type_expense'), label: l10n.txTypeExpense,
                selected: _selectedType == 'expense',
                onTap: () => setState(() => _selectedType = 'expense'),
              ),
              const SizedBox(width: 8),
              SettingsStyle.flatChip(
                key: const Key('settings_cat_type_income'), label: l10n.txTypeIncome,
                selected: _selectedType == 'income',
                onTap: () => setState(() => _selectedType = 'income'),
              ),
            ]),
            GestureDetector(
              key: const Key('settings_add_category_toggle'), behavior: HitTestBehavior.opaque,
              onTap: _openAdd,
              child: Text(_isFormOpen ? l10n.catCancelBtn : l10n.catAddBtn, style: SettingsStyle.accent),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isFormOpen) ...[
          Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 50,
              decoration: BoxDecoration(color: previewColor, borderRadius: BorderRadius.circular(999)),
              child: Icon(CategoryIconResolver.mapCategoryIcon(_selectedIcon), size: 18, color: isDarkIcon ? const Color(0xFF0C0D11) : Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const Key('settings_new_category_input'), controller: _nameCtrl, style: SettingsStyle.title,
                decoration: InputDecoration(
                  hintText: l10n.hintCategoryName, hintStyle: SettingsStyle.sub, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.canvasBorder)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: previewColor)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(key: const Key('settings_save_category_button'), onTap: _submitCategory, child: Text(l10n.catSaveBtn, style: SettingsStyle.accent)),
          ]),
          const SizedBox(height: 12),
          CategoryColorPicker(selectedColor: _selectedColor, onColorChanged: (c) => setState(() => _selectedColor = c)),
          const SizedBox(height: 12),
          CategoryIconPicker(selectedIcon: _selectedIcon, accentColor: previewColor, onIconChanged: (icon) => setState(() => _selectedIcon = icon)),
          const SizedBox(height: 16),
        ],
        CategoryCapsuleTimeline(
          categories: filtered,
          selectedCategoryId: _selectedCategoryId,
          onSelectCategory: (id) => setState(() => _selectedCategoryId = id),
          onEditCategory: _openEdit,
          onDeleteCategory: (cat) => _confirmDelete(context, cat),
        ),
      ],
    );
  }
}
