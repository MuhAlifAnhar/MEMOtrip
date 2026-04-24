import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_typography.dart';
import '../core/services/auth_service.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'app.dart';

/// Auth Gate — Reactive auth guard with polished splash screen.
///
/// Listens to [AuthService.authStateChanges] and renders:
/// - Branded splash while checking auth state
/// - [LoginPage] when signed out (with fade transition)
/// - [AppShell] when signed in (with fade transition)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  /// Track whether we've resolved the initial auth state.
  bool _resolved = false;

  /// The resolved auth destination (null = login, non-null = home).
  User? _resolvedUser;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // ─── Still connecting → show branded splash ────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        // ─── Auth state resolved ───────────────────────
        final user = snapshot.data;

        // First time resolving: trigger fade-in
        if (!_resolved) {
          _resolved = true;
          _resolvedUser = user;
          _fadeCtrl.forward();
        }

        // Subsequent auth state changes: cross-fade
        if (_resolved && user != _resolvedUser) {
          _resolvedUser = user;
          _fadeCtrl.reset();
          _fadeCtrl.forward();
        }

        final destination =
            user != null ? const AppShell() : const LoginPage();

        return FadeTransition(
          opacity: _fadeAnim,
          child: destination,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Branded Splash Screen — shown while Firebase checks auth state
// ─────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ─── Logo with pulse animation ──────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Transform.scale(
                  scale: 0.6 + 0.4 * v,
                  child: Opacity(opacity: v, child: child),
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ─── App Name ──────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, child) => Transform.translate(
                  offset: Offset(0, 12 * (1 - v)),
                  child: Opacity(opacity: v, child: child),
                ),
                child: Text(
                  AppStrings.appName,
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ─── Tagline ──────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Text(
                  AppStrings.appTagline,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ─── Loading indicator ─────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (_, v, child) =>
                    Opacity(opacity: v, child: child),
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      'Menyiapkan perjalananmu...',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // ─── Version ──────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Text(
                  'v1.0.0',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white30,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
