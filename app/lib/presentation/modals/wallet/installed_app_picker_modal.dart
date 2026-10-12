import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/native_bridge/notification_bridge.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class InstalledAppPickerModal extends StatefulWidget {
  const InstalledAppPickerModal({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const InstalledAppPickerModal(),
    );
  }

  @override
  State<InstalledAppPickerModal> createState() => _InstalledAppPickerModalState();
}

class _InstalledAppPickerModalState extends State<InstalledAppPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allApps = [];
  List<Map<String, String>> _filteredApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    final apps = await NotificationBridge.getInstalledBankApps();
    if (!mounted) return;
    if (apps.isEmpty) {
      _allApps = kPopularBankAppPresets
          .map((p) => {'appName': p.name, 'packageName': p.packageName})
          .toList();
    } else {
      apps.sort((a, b) => (a['appName'] ?? '').compareTo(b['appName'] ?? ''));
      _allApps = apps;
    }
    setState(() {
      _filteredApps = List.from(_allApps);
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredApps = List.from(_allApps);
      } else {
        _filteredApps = _allApps.where((app) {
          final name = (app['appName'] ?? '').toLowerCase();
          final pkg = (app['packageName'] ?? '').toLowerCase();
          return name.contains(q) || pkg.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const ModalGrabHandle(),
          ModalHeader(
            title: 'Pilih Aplikasi',
            subtitle: 'Cari bank atau e-wallet di HP Anda',
            onClose: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: AppTypography.listTitle,
              decoration: InputDecoration(
                hintText: 'Cari nama app atau package...',
                hintStyle: AppTypography.listSubtitle,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.canvasInputSearch,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.neoMint))
                : _filteredApps.isEmpty
                    ? Center(
                        child: Text('Aplikasi tidak ditemukan', style: AppTypography.listSubtitle),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _filteredApps.length,
                        separatorBuilder: (_, _) => const Divider(color: AppColors.canvasBorder, height: 1),
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          final name = app['appName'] ?? 'App';
                          final pkg = app['packageName'] ?? '';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.android_rounded, color: AppColors.neoChartreuse, size: 20),
                            ),
                            title: Text(name, style: AppTypography.listTitle),
                            subtitle: Text(pkg, style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 11)),
                            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                            onTap: () => Navigator.of(context).pop(pkg),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
