import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom shape clipper that renders the signature Asymmetric File Folder Tab
class FolderTabClipper extends CustomClipper<Path> {
  final double tabWidthFactor;
  final double cornerRadius;
  final double stepDepth;

  const FolderTabClipper({
    this.tabWidthFactor = 0.54,
    this.cornerRadius = 22.0,
    this.stepDepth = 16.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final tabW = size.width * tabWidthFactor;
    final r = cornerRadius;
    final s = stepDepth;

    // Start at bottom left
    path.moveTo(0, size.height - r);
    path.quadraticBezierTo(0, size.height, r, size.height);

    // Bottom right
    path.lineTo(size.width - r, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - r);

    // Right edge up to tab drop shoulder
    path.lineTo(size.width, s + r);
    path.quadraticBezierTo(size.width, s, size.width - r, s);

    // Flat middle ridge
    path.lineTo(tabW + r, s);

    // Smooth organic S-curve curve down from tab top to shoulder
    path.cubicTo(
      tabW + (r * 0.25), s,
      tabW, 0,
      tabW - (r * 0.75), 0,
    );

    // Top left tab shoulder
    path.lineTo(r, 0);
    path.quadraticBezierTo(0, 0, 0, r);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class FolderTabCard extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final double? width;
  final double height;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const FolderTabCard({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.width,
    this.height = 145,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: const FolderTabClipper(),
        child: Container(
          width: width,
          height: height,
          color: backgroundColor,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
