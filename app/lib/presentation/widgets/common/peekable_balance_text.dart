import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';

/// Displays a formatted currency balance that automatically masks itself
/// when privacy mode (`isBalanceHidden`) is active, providing an inline
/// eye button (`Icons.visibility_outlined`) to peek at the individual value.
class PeekableBalanceText extends StatefulWidget {
  final String text;
  final String? maskedText;
  final TextStyle style;
  final bool? isHidden;
  final Color? iconColor;
  final double? iconSize;
  final TextAlign? textAlign;
  final MainAxisAlignment mainAxisAlignment;
  final Key? eyeKey;

  const PeekableBalanceText({
    super.key,
    required this.text,
    required this.style,
    this.maskedText,
    this.isHidden,
    this.iconColor,
    this.iconSize,
    this.textAlign,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.eyeKey,
  });

  static String mask(String input) {
    if (input.contains('•')) return input;
    final prefix = RegExp(r'^[^\d]+').firstMatch(input)?.group(0) ?? '';
    return '$prefix•••••••';
  }

  @override
  State<PeekableBalanceText> createState() => _PeekableBalanceTextState();
}

class _PeekableBalanceTextState extends State<PeekableBalanceText> {
  bool _peeking = false;
  bool _lastHidden = false;

  bool _resolveHidden(BuildContext context) {
    if (widget.isHidden != null) return widget.isHidden!;
    try {
      return context.select<FinanceBloc, bool>((b) => b.state.isBalanceHidden);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hidden = _resolveHidden(context);
    if (hidden != _lastHidden) {
      _lastHidden = hidden;
      if (!hidden) _peeking = false;
    }

    if (!hidden) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: widget.textAlign,
      );
    }

    final display = _peeking ? widget.text : (widget.maskedText ?? PeekableBalanceText.mask(widget.text));
    final baseFontSize = widget.style.fontSize ?? 16.0;
    final effectiveSize = widget.iconSize ?? (baseFontSize * 0.78).clamp(13.0, 18.0);
    final effectiveColor = widget.iconColor ?? (widget.style.color ?? Colors.white).withValues(alpha: 0.72);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.mainAxisAlignment,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            display,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: widget.textAlign,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          key: widget.eyeKey,
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _peeking = !_peeking),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              _peeking ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: effectiveSize,
              color: effectiveColor,
            ),
          ),
        ),
      ],
    );
  }
}
