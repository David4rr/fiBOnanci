import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/smart_input/smart_input_bridge.dart';
import '../../core/smart_input/smart_transaction_draft.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/common_widgets.dart';

/// Minimalist Obsidian Voice Capture Modal using headless on-device SpeechRecognizer
/// with live waveform pulse, real-time transcript, and clean keyboard toggle.
class SmartInputFallbackSheet extends StatefulWidget {
  final SmartInputSource source;
  const SmartInputFallbackSheet({super.key, required this.source});

  static Future<String?> show(BuildContext context, SmartInputSource source) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => SmartInputFallbackSheet(source: source),
    );
  }

  @override
  State<SmartInputFallbackSheet> createState() =>
      _SmartInputFallbackSheetState();
}

class _NominalHighlightController extends TextEditingController {
  static final _incomeRx = RegExp(
    r'\b(gaji|gajian|upah|bonus|thr|terima|dapat|masuk|pemasukan|income|refund|cashback|dividen|komisi|jualan|untung|laba|kiriman)\b',
    caseSensitive: false,
  );
  static final _nominalRx = RegExp(
    r'(?:(?:rp|idr)\.?\s*)?(?:\d+(?:[.,]\d+)*(?:\s*(?:ribu|rb|k|juta|jt|ratus|puluh))?|\b(?:satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|belas|puluh|seratus|ratus|seribu|ribu|sejuta|juta|setengah)(?:\s+(?:satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|belas|puluh|seratus|ratus|seribu|ribu|sejuta|juta|setengah))*\b)',
    caseSensitive: false,
  );

  static TextSpan buildHighlightedSpan(String src, TextStyle? baseStyle) {
    final nominalColor = _incomeRx.hasMatch(src) ? AppColors.neoMint : AppColors.statusDeficit;
    final spans = <InlineSpan>[];
    int cursor = 0;
    for (final m in _nominalRx.allMatches(src)) {
      if (m.start > cursor) spans.add(TextSpan(text: src.substring(cursor, m.start)));
      spans.add(TextSpan(text: m.group(0), style: baseStyle?.copyWith(color: nominalColor, fontWeight: FontWeight.w800)));
      cursor = m.end;
    }
    if (cursor < src.length) spans.add(TextSpan(text: src.substring(cursor)));
    return TextSpan(style: baseStyle, children: spans);
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) =>
      buildHighlightedSpan(text, style);
}

class _SmartInputFallbackSheetState extends State<SmartInputFallbackSheet> {
  final _controller = _NominalHighlightController();
  bool _isListening = false, _showKeyboard = false;
  double _rms = 0.0;
  String _transcript = '';
  Timer? _autoDoneTimer;

  @override
  void initState() {
    super.initState();
    if (widget.source == SmartInputSource.voice) { _startVoice(); } else { _showKeyboard = true; }
  }

  Future<void> _startVoice() async {
    setState(() { _isListening = true; _rms = 0.2; });
    final status = await SmartInputBridge.startHeadlessListening(
      onEvent: (event) {
        if (!mounted) return;
        final type = event['type'] as String? ?? '';
        final text = (event['text'] as String? ?? '').trim();
        if (type == 'partial') {
          setState(() { _transcript = text; _controller.text = text; });
        } else if (type == 'final') {
          setState(() {
            _isListening = false; _rms = 0.0;
            if (text.isNotEmpty) { _transcript = text; _controller.text = text; }
          });
          if (_transcript.isNotEmpty) {
            _autoDoneTimer?.cancel();
            _autoDoneTimer = Timer(const Duration(milliseconds: 280), _submit);
          }
        } else if (type == 'rms') {
          final raw = (event['rms'] as num?)?.toDouble() ?? 0.0;
          setState(() => _rms = ((raw + 2.0) / 12.0).clamp(0.05, 1.0));
        } else if (type == 'unavailable' || type == 'error') {
          setState(() { _isListening = false; _rms = 0.0; });
        }
      },
    );
    if (mounted && status == 'UNAVAILABLE') setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _autoDoneTimer?.cancel();
    SmartInputBridge.cancelHeadlessListening();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = (_showKeyboard ? _controller.text : _transcript).trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context, text);
  }
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasText = (_showKeyboard ? _controller.text : _transcript).trim().isNotEmpty;
    final ringSize = 76.0 + (_isListening ? (_rms * 26.0) : 0.0);

    return IPhoneViewportContainer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + bottomInset),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          decoration: BoxDecoration(
            color: AppColors.canvasCardSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _isListening ? AppColors.neoChartreuse : AppColors.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Text(_isListening ? 'Mendengarkan...' : 'Input Suara', style: AppTypography.listSubtitle.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showKeyboard = !_showKeyboard),
                    child: Icon(_showKeyboard ? Icons.mic_none_rounded : Icons.keyboard_alt_outlined, size: 19, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close_rounded, size: 19, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 24),
              if (!_showKeyboard) ...[
                GestureDetector(
                  onTap: () => _isListening ? SmartInputBridge.stopHeadlessListening() : _startVoice(),
                  child: SizedBox(
                    width: 104, height: 104,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: ringSize, height: ringSize,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neoChartreuse.withValues(alpha: _isListening ? 0.12 : 0.04)),
                        child: Center(
                          child: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: _isListening ? AppColors.neoChartreuse : AppColors.canvasInputSearch, border: Border.all(color: AppColors.neoChartreuse, width: 1.4)),
                            child: Icon(_isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded, color: _isListening ? AppColors.textDarkPrimary : AppColors.neoChartreuse, size: 26),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _transcript.isEmpty
                    ? Text('Ucapkan transaksi Anda...', textAlign: TextAlign.center, style: AppTypography.listSubtitle.copyWith(fontSize: 14, color: AppColors.textMuted))
                    : Text.rich(_NominalHighlightController.buildHighlightedSpan(_transcript, AppTypography.listTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w600)), textAlign: TextAlign.center),
              ] else ...[
                AppTextField(controller: _controller, maxLines: 2, hintText: 'Ketik kalimat transaksi...', onChanged: (v) => setState(() => _transcript = v)),
              ],
              if (hasText) ...[
                const SizedBox(height: 20),
                PrimaryActionButton(text: 'Lanjutkan', onPressed: _submit),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
