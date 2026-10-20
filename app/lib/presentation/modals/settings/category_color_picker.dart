import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CategoryColorPicker extends StatefulWidget {
  final String selectedColor;
  final ValueChanged<String> onColorChanged;

  const CategoryColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  static const palette = [
    '#D4F442', '#10B981', '#14B8A6', '#06B6D4',
    '#3B82F6', '#6366F1', '#8B5CF6', '#A855F7',
    '#EC4899', '#F43F5E', '#EF4444', '#F97316',
    '#F59E0B', '#D97706', '#78716C', '#64748B',
  ];

  static Color parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    final val = int.tryParse('FF$cleaned', radix: 16);
    return val != null ? Color(val) : AppColors.neoChartreuse;
  }

  @override
  State<CategoryColorPicker> createState() => _CategoryColorPickerState();
}

class _CategoryColorPickerState extends State<CategoryColorPicker> {
  bool _customHexOpen = false;
  late final TextEditingController _hexCtrl;

  @override
  void initState() {
    super.initState();
    _hexCtrl = TextEditingController(text: widget.selectedColor);
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  void _onHexSubmitted(String val) {
    final clean = val.replaceAll('#', '').trim();
    if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(clean)) {
      widget.onColorChanged('#${clean.toUpperCase()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PILIH WARNA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _customHexOpen = !_customHexOpen),
              child: Text(
                _customHexOpen ? 'Tutup HEX' : '# Custom HEX',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neoChartreuse,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_customHexOpen) ...[
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CategoryColorPicker.parseColor(widget.selectedColor),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hexCtrl,
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'Misal: #FF6B6B',
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.white38),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: _onHexSubmitted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: CategoryColorPicker.palette.map((hex) {
            final active = widget.selectedColor.toUpperCase() == hex.toUpperCase();
            return GestureDetector(
              key: Key('color_chip_$hex'),
              onTap: () {
                _hexCtrl.text = hex;
                widget.onColorChanged(hex);
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CategoryColorPicker.parseColor(hex),
                  border: active ? Border.all(color: Colors.white, width: 2.2) : null,
                  boxShadow: active
                      ? [BoxShadow(color: CategoryColorPicker.parseColor(hex).withValues(alpha: 0.5), blurRadius: 6)]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
