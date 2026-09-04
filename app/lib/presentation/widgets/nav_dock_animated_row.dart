import 'package:flutter/material.dart';

import 'nav_dock_components.dart';

class DockItemData {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const DockItemData({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AnimatedNavDockRow extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTapIndex;
  final List<DockItemData> items;

  const AnimatedNavDockRow({
    super.key,
    required this.currentIndex,
    required this.onTapIndex,
    required this.items,
  });

  @override
  State<AnimatedNavDockRow> createState() => _AnimatedNavDockRowState();
}

class _AnimatedNavDockRowState extends State<AnimatedNavDockRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<double> _prevWeights;
  late List<double> _targetWeights;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _targetWeights = _computeWeights(widget.currentIndex);
    _prevWeights = List<double>.from(_targetWeights);
  }

  @override
  void didUpdateWidget(covariant AnimatedNavDockRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _prevWeights = _currentWeights();
      _targetWeights = _computeWeights(widget.currentIndex);
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _computeWeights(int index) {
    return List<double>.generate(
      widget.items.length,
      (i) => i == index ? 1.35 : 1.0,
    );
  }

  List<double> _currentWeights() {
    final t = _animation.value;
    return List<double>.generate(
      widget.items.length,
      (i) => _prevWeights[i] + (_targetWeights[i] - _prevWeights[i]) * t,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final weights = _currentWeights();
            final sumWeights = weights.reduce((a, b) => a + b);

            return Row(
              children: List<Widget>.generate(widget.items.length, (i) {
                final item = widget.items[i];
                final width = (weights[i] / sumWeights) * totalWidth;
                return SizedBox(
                  width: width,
                  child: NavItemWidget(
                    isActive: widget.currentIndex == item.index,
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    label: item.label,
                    onTap: () => widget.onTapIndex(item.index),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}
