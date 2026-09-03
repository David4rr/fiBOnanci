import 'package:flutter/material.dart';

/// Vertically stacked deck of cards overlapping by negative vertical step
class OverlappingDeckList extends StatelessWidget {
  final List<Widget> children;
  final double overlapOffset;
  final double stepOffset;
  final double cardHeight;

  const OverlappingDeckList({
    super.key,
    required this.children,
    this.overlapOffset = 70.0,
    this.stepOffset = 95.0,
    this.cardHeight = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalHeight = (children.length - 1) * stepOffset + cardHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < children.length; i++)
            Positioned(
              top: i * stepOffset,
              left: 0,
              right: 0,
              child: children[i],
            ),
        ],
      ),
    );
  }
}
