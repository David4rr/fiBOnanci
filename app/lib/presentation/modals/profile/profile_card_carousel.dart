import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import 'profile_header_card.dart';

class ProfileCardCarousel extends StatefulWidget {
  final List<ProfileEntry> profiles;
  final String currentProfileId;
  final int? walletCount;
  final int? txCount;
  final VoidCallback? onEditProfile;
  final VoidCallback? onNewProfile;
  final VoidCallback? onHealthDetails;

  const ProfileCardCarousel({
    super.key,
    required this.profiles,
    required this.currentProfileId,
    this.walletCount,
    this.txCount,
    this.onEditProfile,
    this.onNewProfile,
    this.onHealthDetails,
  });

  @override
  State<ProfileCardCarousel> createState() => _ProfileCardCarouselState();
}

class _ProfileCardCarouselState extends State<ProfileCardCarousel> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    final activeIdx = widget.profiles.indexWhere((p) => p.id == widget.currentProfileId);
    _currentPage = activeIdx >= 0 ? activeIdx : 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(covariant ProfileCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activeIdx = widget.profiles.indexWhere((p) => p.id == widget.currentProfileId);
    if (activeIdx >= 0 && activeIdx != _currentPage && _pageController.hasClients) {
      _currentPage = activeIdx;
      _pageController.animateToPage(
        activeIdx,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    if (index >= 0 && index < widget.profiles.length) {
      final target = widget.profiles[index];
      if (target.id != widget.currentProfileId) {
        context.read<FinanceBloc>().add(SetActiveProfileEvent(target.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profiles.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.profiles.length == 1) {
      return ProfileHeaderCard(
        profile: widget.profiles.first,
        totalProfiles: 1,
        walletCount: widget.walletCount,
        txCount: widget.txCount,
        onEditProfile: widget.onEditProfile,
        onNewProfile: widget.onNewProfile,
        onHealthDetails: widget.onHealthDetails,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 310,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.profiles.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final p = widget.profiles[index];
              return ProfileHeaderCard(
                key: ValueKey('profile_card_${p.id}'),
                profile: p,
                totalProfiles: widget.profiles.length,
                walletCount: widget.walletCount,
                txCount: widget.txCount,
                onEditProfile: widget.onEditProfile,
                onNewProfile: widget.onNewProfile,
                onHealthDetails: widget.onHealthDetails,
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        _buildIndicatorsAndControls(),
      ],
    );
  }

  Widget _buildIndicatorsAndControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.profiles.length, (i) {
        final isCurrent = i == _currentPage;
        return GestureDetector(
          key: ValueKey('profile_carousel_dot_$i'),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _onPageChanged(i);
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              width: isCurrent ? 24 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.neoChartreuse : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }),
    );
  }
}
