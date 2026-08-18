import 'dart:math';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';
import '../core/services/auth_service.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'app.dart';

/// Auth Gate — Shows branded splash screen first, then transitions
/// to Login or Home based on Firebase auth state.
///
/// Flow: Splash (2.5s) → fade-out → Login or AppShell
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with TickerProviderStateMixin {
  /// Phase: 0 = splash, 1 = destination (login or home)
  int _phase = 0;

  /// Resolved Firebase user (null = not signed in)
  User? _resolvedUser;

  /// Whether auth state has been resolved at least once.
  bool _authResolved = false;

  // ─── Splash exit animation ─────────────────────────────
  late final AnimationController _splashExitCtrl;
  late final Animation<double> _splashFadeOut;

  // ─── Destination entrance animation ────────────────────
  late final AnimationController _destEntranceCtrl;
  late final Animation<double> _destFadeIn;
  late final Animation<Offset> _destSlideIn;

  @override
  void initState() {
    super.initState();

    _splashExitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _splashFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _splashExitCtrl, curve: Curves.easeIn),
    );

    _destEntranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _destFadeIn =
        CurvedAnimation(parent: _destEntranceCtrl, curve: Curves.easeOut);
    _destSlideIn = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _destEntranceCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _splashExitCtrl.dispose();
    _destEntranceCtrl.dispose();
    super.dispose();
  }

  /// Called when auth state is first resolved (from StreamBuilder).
  /// Waits for splash minimum duration, then transitions.
  Future<void> _onAuthResolved(User? user) async {
    if (_authResolved) return;
    _authResolved = true;
    _resolvedUser = user;

    if (user != null) {
      AuthService.ensureUserRole();
    }

    // Ensure splash shows for at least 2.5 seconds total
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Phase 1: Fade out splash
    await _splashExitCtrl.forward();
    if (!mounted) return;

    // Phase 2: Switch to destination and fade in
    setState(() => _phase = 1);
    _destEntranceCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Capture auth resolution
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          _onAuthResolved(snapshot.data);
        }

        // After auth changes post-initial (e.g., logout/login)
        if (_authResolved && _phase == 1) {
          final user = snapshot.data;
          if (user != _resolvedUser) {
            _resolvedUser = user;
            _destEntranceCtrl.reset();
            _destEntranceCtrl.forward();
          }

          final destination =
              user != null ? const AppShell() : const LoginPage();

          return FadeTransition(
            opacity: _destFadeIn,
            child: SlideTransition(
              position: _destSlideIn,
              child: destination,
            ),
          );
        }

        // ── Splash phase ─────────────────────────────────
        return FadeTransition(
          opacity: _splashFadeOut,
          child: const _BrandedSplash(),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  Branded Splash Screen — matching the requested animation design.
//  The logo and text are perfectly centered, surrounded by looping,
//  animated geometric corner blobs as shown in the mockup image.
// ═════════════════════════════════════════════════════════════
class _BrandedSplash extends StatefulWidget {
  const _BrandedSplash();

  @override
  State<_BrandedSplash> createState() => _BrandedSplashState();
}

class _BrandedSplashState extends State<_BrandedSplash>
    with TickerProviderStateMixin {
  // Looping animation controller for the background blobs
  late final AnimationController _loopCtrl;

  // Staggered intro animations for logo, text, and general opacity
  late final AnimationController _introCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<double> _introBlobFade;

  @override
  void initState() {
    super.initState();

    // 1. Intro Animations (once on start)
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _introBlobFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _introCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
          parent: _introCtrl,
          curve: const Interval(0.15, 0.65, curve: Curves.easeOutBack)),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _introCtrl,
          curve: const Interval(0.15, 0.55, curve: Curves.easeOut)),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _introCtrl,
          curve: const Interval(0.5, 0.85, curve: Curves.easeOut)),
    );

    _introCtrl.forward();

    // 2. Looping Blob Position Animation (6 seconds cycle, repeated)
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _loopCtrl.dispose();
    super.dispose();
  }

  /// Helper to interpolate position values based on current loop animation phase.
  /// Represents the transition through the 4 frames of the design image.
  double _getBlobValue({
    required double t,
    required double f1,
    required double f2,
    required double f3,
    required double f4,
  }) {
    if (t < 0.25) {
      // Phase 1: Frame 1 to Frame 2
      final progress = t / 0.25;
      return lerpDouble(f1, f2, Curves.easeInOut.transform(progress))!;
    } else if (t < 0.5) {
      // Phase 2: Frame 2 to Frame 3
      final progress = (t - 0.25) / 0.25;
      return lerpDouble(f2, f3, Curves.easeInOut.transform(progress))!;
    } else if (t < 0.75) {
      // Phase 3: Frame 3 to Frame 4
      final progress = (t - 0.5) / 0.25;
      return lerpDouble(f3, f4, Curves.easeInOut.transform(progress))!;
    } else {
      // Phase 4: Frame 4 back to Frame 1
      final progress = (t - 0.75) / 0.25;
      return lerpDouble(f4, f1, Curves.easeInOut.transform(progress))!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── Looping & Moving Corner Blobs ─────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_loopCtrl, _introBlobFade]),
            builder: (context, _) {
              final t = _loopCtrl.value;
              final introOpacity = _introBlobFade.value;

              // Blob 1: Light blue/purple (#D6E4F7)
              final b1Size =
                  _getBlobValue(t: t, f1: 0.5, f2: 0.3, f3: 0.4, f4: 0.45) * w;
              final b1Top = _getBlobValue(
                      t: t, f1: -0.15, f2: -0.25, f3: -0.05, f4: -0.08) *
                  w;
              final b1Left = _getBlobValue(
                      t: t, f1: -0.15, f2: -0.25, f3: 0.5, f4: -0.08) *
                  w;

              // Blob 2: Medium blue (#3F99D2)
              final b2Size =
                  _getBlobValue(t: t, f1: 0.45, f2: 0.55, f3: 0.5, f4: 0.48) *
                      w;
              final b2Top = _getBlobValue(
                      t: t, f1: -0.05, f2: -0.02, f3: -0.08, f4: -0.03) *
                  w;
              final b2Right =
                  _getBlobValue(t: t, f1: -0.1, f2: 0.1, f3: 0.5, f4: -0.05) *
                      w;

              // Blob 3: Dark navy (#2C3A5C)
              final b3Size =
                  _getBlobValue(t: t, f1: 0.55, f2: 0.65, f3: 0.6, f4: 0.58) *
                      w;
              final b3Bottom = _getBlobValue(
                      t: t, f1: -0.15, f2: -0.1, f3: -0.12, f4: -0.12) *
                  w;
              final b3Left =
                  _getBlobValue(t: t, f1: -0.08, f2: 0.15, f3: 0.4, f4: -0.05) *
                      w;

              // Blob 4: Soft blue/purple (#B1C4F9)
              final b4Size =
                  _getBlobValue(t: t, f1: 0.48, f2: 0.3, f3: 0.45, f4: 0.46) *
                      w;
              final b4Bottom = _getBlobValue(
                      t: t, f1: -0.05, f2: -0.25, f3: -0.08, f4: -0.04) *
                  w;
              final b4Right = _getBlobValue(
                      t: t, f1: -0.12, f2: -0.25, f3: 0.5, f4: -0.08) *
                  w;

              return Opacity(
                opacity: introOpacity,
                child: Stack(
                  children: [
                    // Blob 1 (Light Blue/Purple)
                    Positioned(
                      top: b1Top,
                      left: b1Left,
                      child: Container(
                        width: b1Size,
                        height: b1Size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD6E4F7).withOpacity(0.65),
                        ),
                      ),
                    ),

                    // Blob 2 (Medium Blue)
                    Positioned(
                      top: b2Top,
                      right: b2Right,
                      child: Container(
                        width: b2Size,
                        height: b2Size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3F99D2).withOpacity(0.7),
                        ),
                      ),
                    ),

                    // Blob 3 (Dark Navy)
                    Positioned(
                      bottom: b3Bottom,
                      left: b3Left,
                      child: Container(
                        width: b3Size,
                        height: b3Size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2C3A5C).withOpacity(0.9),
                        ),
                      ),
                    ),

                    // Blob 4 (Soft Blue/Purple)
                    Positioned(
                      bottom: b4Bottom,
                      right: b4Right,
                      child: Container(
                        width: b4Size,
                        height: b4Size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFB1C4F9).withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ─── Center Content: Logo + App Name (Absolutely Centered) ──────
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Image
                  AnimatedBuilder(
                    animation: _introCtrl,
                    builder: (_, child) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(opacity: _logoFade.value, child: child),
                    ),
                    child: Image.asset(
                      'assets/images/logo_memotrip.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // App Name "MEMOtrip"
                  AnimatedBuilder(
                    animation: _textFade,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, 8 * (1 - _textFade.value)),
                      child: Opacity(opacity: _textFade.value, child: child),
                    ),
                    // child: Text(
                    //   'MEMOtrip',
                    //   style: AppTypography.displayMedium.copyWith(
                    //     color: const Color(0xFF2C3A5C),
                    //     fontWeight: FontWeight.w800,
                    //     letterSpacing: 1.0,
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Version at bottom ─────────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textFade,
              builder: (_, child) =>
                  Opacity(opacity: _textFade.value * 0.5, child: child),
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF2C3A5C).withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
