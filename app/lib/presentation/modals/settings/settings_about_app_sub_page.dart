import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/native_bridge/notification_bridge.dart';
import '../../../core/storage/profile_preferences_storage.dart';
import '../../../core/update/app_update_downloader.dart';
import '../../../core/update/app_update_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'in_app_update_progress_card.dart';
import 'settings_about_app_components.dart';
import 'settings_style.dart';

export 'settings_about_app_components.dart';

class SettingsAboutAppSubPage extends StatefulWidget {
  const SettingsAboutAppSubPage({super.key});

  @override
  State<SettingsAboutAppSubPage> createState() => _SettingsAboutAppSubPageState();
}

class _SettingsAboutAppSubPageState extends State<SettingsAboutAppSubPage> {
  bool _isChecking = false;
  bool _hasChecked = false;
  AppUpdateInfo? _updateInfo;
  bool _autoCheck = ProfilePreferencesStorage.getAutoUpdateCheck();
  int? _downloadId;
  DownloadProgressInfo? _progressInfo;
  StreamSubscription? _downloadSub;

  @override
  void initState() {
    super.initState();
    if (_autoCheck) _checkUpdate();
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }

  Future<void> _checkUpdate() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    final info = await AppUpdateService.checkForUpdate();
    if (!mounted) return;
    setState(() {
      _updateInfo = info;
      _hasChecked = true;
      _isChecking = false;
    });
  }

  Future<void> _startDownload(AppUpdateInfo info) async {
    final targetUrl = info.apkUrl ?? info.htmlUrl;
    final isApk = targetUrl.toLowerCase().contains('.apk');
    if (!isApk) {
      await NotificationBridge.openUrl(targetUrl);
      return;
    }

    final id = await AppUpdateDownloader.startDownload(targetUrl, fileName: 'fiBOnanci-v${info.latestVersion}.apk');
    if (id <= 0) {
      if (mounted) await NotificationBridge.openUrl(targetUrl);
      return;
    }

    setState(() {
      _downloadId = id;
      _progressInfo = const DownloadProgressInfo(status: 'pending', bytesDownloaded: 0, totalBytes: -1, progress: 0.0);
    });

    _downloadSub?.cancel();
    _downloadSub = AppUpdateDownloader.trackProgress(id).listen((p) {
      if (!mounted) return;
      setState(() => _progressInfo = p);
      if (p.isCompleted) AppUpdateDownloader.install(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
      children: [
        const AboutHeroCard(),
        const SizedBox(height: 24),
        SettingsStyle.sectionHeader('STATUS & PEMBARUAN APLIKASI'),
        const SizedBox(height: 10),
        _buildUpdateSection(),
        const SizedBox(height: 24),
        SettingsStyle.sectionHeader('TENTANG & ARSITEKTUR APLIKASI'),
        const SizedBox(height: 10),
        const AboutSpecsSection(),
      ],
    );
  }

  Widget _buildUpdateSection() {
    final hasUpdate = _updateInfo != null && _updateInfo!.hasUpdate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsStyle.switchRow(
            switchKey: const Key('settings_auto_update_switch'),
            title: 'Pembaruan Otomatis',
            value: _autoCheck,
            onChanged: (v) {
              setState(() => _autoCheck = v);
              ProfilePreferencesStorage.setAutoUpdateCheck(v);
            },
          ),
          Divider(color: AppColors.dividerSubtle, height: 24),
          if (_isChecking)
            Row(children: [
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neoChartreuse)),
              const SizedBox(width: 12),
              Text('Menghubungkan ke GitHub Releases...', style: SettingsStyle.sub),
            ])
          else if (hasUpdate) ...[
            if (_downloadId != null)
              InAppUpdateProgressCard(
                version: _updateInfo!.latestVersion,
                progressInfo: _progressInfo,
                onInstall: () => AppUpdateDownloader.install(_downloadId!),
                onRetry: () => _startDownload(_updateInfo!),
              )
            else ...[
              Row(children: [
                const Icon(Icons.system_update_rounded, color: AppColors.neoChartreuse, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Versi v${_updateInfo!.latestVersion} Siap Diunduh!', style: SettingsStyle.title.copyWith(color: AppColors.textAccent))),
              ]),
              const SizedBox(height: 12),
              PrimaryActionButton(
                key: const Key('about_download_update_button'),
                text: 'Unduh & Pasang Pembaruan',
                icon: Icons.download_rounded,
                onPressed: () => _startDownload(_updateInfo!),
              ),
            ],
            const SizedBox(height: 16),
            Text('Catatan Rilis:', style: SettingsStyle.title),
            const SizedBox(height: 8),
            UserFriendlyChangelogView(releaseNotes: _updateInfo!.releaseNotes),
          ] else ...[
            Row(children: [
              Icon(_hasChecked ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: _hasChecked ? AppColors.neoMint : AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _hasChecked ? 'Aplikasi Sudah Versi Terbaru (v${AppUpdateService.currentVersion})' : 'Belum diperiksa ke repositori rilis',
                  style: SettingsStyle.title.copyWith(color: _hasChecked ? AppColors.textIncome : AppColors.textPrimary),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            GestureDetector(
              key: const Key('about_check_update_now_btn'),
              behavior: HitTestBehavior.opaque,
              onTap: _checkUpdate,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.refresh_rounded, size: 16, color: AppColors.neoChartreuse),
                const SizedBox(width: 6),
                Text('Periksa Pembaruan Sekarang', style: SettingsStyle.accent),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
