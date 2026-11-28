import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/l10n/locale_notifier.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/storage/kofi_prompt_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';

class KofiWebViewModal extends StatefulWidget {
  final String url;

  const KofiWebViewModal({super.key, this.url = KofiPromptStorage.kofiUrl});

  static Future<void> show(BuildContext context) => showUrl(context, url: KofiPromptStorage.kofiUrl);

  static Future<void> showUrl(BuildContext context, {required String url}) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => KofiWebViewModal(url: url),
      );

  @override
  State<KofiWebViewModal> createState() => _KofiWebViewModalState();
}

class _KofiWebViewModalState extends State<KofiWebViewModal> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _hasError = false;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.canvasBg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => mounted ? setState(() => _progress = p) : null,
          onPageStarted: (_) => mounted ? setState(() => _hasError = false) : null,
          onPageFinished: (_) async {
            final back = await _controller.canGoBack();
            if (mounted) setState(() => _canGoBack = back);
          },
          onWebResourceError: (err) {
            if (err.isForMainFrame == true && mounted) {
              setState(() => _hasError = true);
            }
          },
          onNavigationRequest: (req) {
            final uri = Uri.tryParse(req.url);
            if (uri != null && uri.scheme != 'http' && uri.scheme != 'https') {
              NotificationBridge.openUrl(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  String get _displayHost {
    final uri = Uri.tryParse(widget.url);
    if (uri == null || uri.host.isEmpty) return widget.url;
    return '${uri.host}${uri.path == '/' ? '' : uri.path}';
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        border: Border(bottom: BorderSide(color: AppColors.canvasBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModalGrabHandle(),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_canGoBack)
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 20),
                  onPressed: () => _controller.goBack(),
                  visualDensity: VisualDensity.compact,
                )
              else
                const SizedBox(width: 12),
              Icon(Icons.lock_rounded, color: AppColors.neoMint, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _displayHost,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 22),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 42),
            const SizedBox(height: 12),
            Text(
              l10n.webViewErrorTitle,
              style: TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.webViewErrorBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            PrimaryActionButton(
              text: l10n.webViewRetryBtn,
              onPressed: () {
                setState(() => _hasError = false);
                _controller.reload();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.88;
    return IPhoneViewportContainer(
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.canvasBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            if (_progress < 100 && !_hasError)
              LinearProgressIndicator(
                value: _progress / 100,
                minHeight: 2.5,
                backgroundColor: AppColors.canvasCardSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(KofiSupportButton.kofiRed),
              ),
            Expanded(
              child: _hasError ? _buildErrorView() : WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
