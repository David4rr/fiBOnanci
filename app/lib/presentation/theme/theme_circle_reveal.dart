import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_theme.dart';

/// Custom clipper that clips an expanding circle from [center] with [radius].
class CircularRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  const CircularRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CircularRevealClipper oldClipper) =>
      oldClipper.radius != radius || oldClipper.center != center;
}

/// A root widget that wraps the application and performs a circular reveal transition
/// whenever the theme changes.
class ThemeCircleReveal extends StatefulWidget {
  final Widget child;

  const ThemeCircleReveal({super.key, required this.child});

  static ThemeCircleRevealState? of(BuildContext context) =>
      context.findAncestorStateOfType<ThemeCircleRevealState>();

  @override
  State<ThemeCircleReveal> createState() => ThemeCircleRevealState();
}

class ThemeCircleRevealState extends State<ThemeCircleReveal>
    with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  late final AnimationController _animController;
  late final Animation<double> _animCurve;
  ui.Image? _oldImage;
  Offset _revealCenter = Offset.zero;
  double _maxRadius = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _cleanup();
        }
      });
    _animCurve = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    registerThemeSwitchHandler(_switchThemeWithReveal);
  }

  @override
  void dispose() {
    registerThemeSwitchHandler(null);
    _animController.dispose();
    _oldImage?.dispose();
    super.dispose();
  }

  void _cleanup() {
    if (mounted) {
      setState(() {
        _oldImage?.dispose();
        _oldImage = null;
      });
    }
  }

  Future<void> _switchThemeWithReveal(ThemeMode mode, {Offset? origin}) async {
    if (!mounted) {
      setAppThemeMode(mode);
      return;
    }

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        setAppThemeMode(mode);
        return;
      }

      final media = MediaQuery.maybeOf(context);
      final pixelRatio = media?.devicePixelRatio ?? 1.0;
      final size = media?.size ?? boundary.size;

      final center = origin ?? Offset(size.width / 2, size.height / 2);
      final dx = math.max(center.dx, size.width - center.dx);
      final dy = math.max(center.dy, size.height - center.dy);
      final maxR = math.sqrt(dx * dx + dy * dy);

      final image = await boundary.toImage(pixelRatio: pixelRatio);

      setState(() {
        _oldImage?.dispose();
        _oldImage = image;
        _revealCenter = center;
        _maxRadius = maxR;
      });

      setAppThemeMode(mode);
      _animController.forward(from: 0.0);
    } catch (_) {
      setAppThemeMode(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animCurve,
      builder: (context, _) {
        final isAnimating = _oldImage != null && _animController.isAnimating;
        final currentRadius = _maxRadius * _animCurve.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (isAnimating && _oldImage != null)
              Positioned.fill(
                child: RawImage(
                  image: _oldImage,
                  fit: BoxFit.cover,
                ),
              ),
            Positioned.fill(
              child: ClipPath(
                clipBehavior: isAnimating ? Clip.antiAlias : Clip.none,
                clipper: isAnimating
                    ? CircularRevealClipper(
                        center: _revealCenter,
                        radius: currentRadius,
                      )
                    : null,
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
