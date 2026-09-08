import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import 'profile_morphing_menu_overlay.dart';

export 'profile_morphing_menu_overlay.dart';

class ProfileMorphingMenu extends StatefulWidget {
  final ProfileEntry profile;
  final int totalProfiles;
  final VoidCallback? onEditProfile;
  final VoidCallback? onNewProfile;
  final VoidCallback? onHealthDetails;

  const ProfileMorphingMenu({
    super.key,
    required this.profile,
    required this.totalProfiles,
    this.onEditProfile,
    this.onNewProfile,
    this.onHealthDetails,
  });

  @override
  State<ProfileMorphingMenu> createState() => _ProfileMorphingMenuState();
}

class _ProfileMorphingMenuState extends State<ProfileMorphingMenu>
    with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();
  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openMenu() {
    setState(() => _isExpanded = true);
    _overlayController.show();
    _animController.forward(from: 0.0);
  }

  void _closeMenu({VoidCallback? onComplete}) {
    if (!_isExpanded) return;
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() => _isExpanded = false);
        _overlayController.hide();
        onComplete?.call();
      }
    });
  }

  void _shareProfile() {
    Clipboard.setData(ClipboardData(
      text: '${widget.profile.fullName} (@${widget.profile.username}) - fiBOnanci',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kartu profil berhasil disalin!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _closeMenu(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.topRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 0),
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) => FadeTransition(
                  opacity: _expandAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.35, end: 1.0).animate(_expandAnimation),
                    alignment: Alignment.topRight,
                    child: child,
                  ),
                ),
                child: ProfileMorphingMenuOverlay(
                  profile: widget.profile,
                  totalProfiles: widget.totalProfiles,
                  onClose: _closeMenu,
                  onAction: (action) => _closeMenu(onComplete: action),
                  onEditProfile: widget.onEditProfile,
                  onNewProfile: widget.onNewProfile,
                  onHealthDetails: widget.onHealthDetails,
                  onShareProfile: _shareProfile,
                ),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            _isExpanded ? _closeMenu() : _openMenu();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isExpanded ? AppColors.neoChartreuse.withValues(alpha: 0.15) : Colors.transparent,
              border: _isExpanded
                  ? Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.4), width: 1.0)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.more_horiz_rounded, size: 24, color: Colors.transparent),
                IgnorePointer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: EdgeInsets.only(left: i > 0 ? 5.5 : 0.0),
                        width: 7.0,
                        height: 7.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isExpanded ? AppColors.neoChartreuse : const Color(0xFF8E92A0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
