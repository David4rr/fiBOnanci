import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/native_bridge/security_bridge.dart';
import '../../theme/app_colors.dart';
import '../folder_tab_card.dart';
import 'primary_action_button.dart';
import 'fibonanci_logo_mark.dart';
import 'fibonanci_splash_gate.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;
  DateTime? _lastPausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  @override
  void dispose() {
    FibonanciSplashGate.isSplashActive.removeListener(_onSplashFinished);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSplashFinished() {
    if (!FibonanciSplashGate.isSplashActive.value && mounted && _isLocked) {
      FibonanciSplashGate.isSplashActive.removeListener(_onSplashFinished);
      _unlock();
    }
  }

  Future<void> _checkInitialLock() async {
    final settings = await SecurityBridge.getSecuritySettings();
    if (!mounted) return;
    if (settings.biometricLockEnabled) {
      setState(() => _isLocked = true);
      if (FibonanciSplashGate.isSplashActive.value) {
        FibonanciSplashGate.isSplashActive.addListener(_onSplashFinished);
      } else {
        await _unlock();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final pausedAt = _lastPausedAt;
      _lastPausedAt = null;
      if (pausedAt != null &&
          DateTime.now().difference(pausedAt).inSeconds >= 15 &&
          !_isAuthenticating) {
        _checkLockOnResume();
      }
    }
  }

  Future<void> _checkLockOnResume() async {
    final settings = await SecurityBridge.getSecuritySettings();
    if (!mounted) return;
    if (settings.biometricLockEnabled && !_isLocked) {
      setState(() => _isLocked = true);
      await _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    final ok = await SecurityBridge.authenticateBiometric(
      reason: 'Verifikasi sidik jari atau PIN untuk membuka brankas fiBOnanci',
    );
    if (!mounted) return;
    setState(() {
      _isAuthenticating = false;
      if (ok) _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked)
          Positioned.fill(
            child: Material(
              key: const Key('app_lock_overlay'),
              color: AppColors.canvasBg,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        foregroundPainter: const FolderTabBorderPainter(
                          borderColor: Color(0xFF262936),
                          borderWidth: 1.1,
                        ),
                        child: ClipPath(
                          clipper: const FolderTabClipper(),
                          child: Container(
                            color: AppColors.carbonBlack,
                            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.neoChartreuse,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'TERKUNCI • AES-256 VAULT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.neoChartreuse,
                                        letterSpacing: 0.9,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const FibonanciLogoMark(size: 34),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Brankas Terkunci',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textWhite,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Data keuangan dienkripsi di perangkat. Gunakan sidik jari, wajah, atau PIN untuk membuka.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                PrimaryActionButton(
                                  key: const Key('app_lock_unlock_btn'),
                                  text: 'Buka Kunci Aplikasi',
                                  icon: Icons.fingerprint_rounded,
                                  isLoading: _isAuthenticating,
                                  onPressed: _unlock,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
