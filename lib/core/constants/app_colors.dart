import 'package:flutter/material.dart';

/// MEMOtrip Design Tokens — Color Palette
///
/// PRD Visual Guide:
/// - Primary: Sky Blue gradient
/// - Surface: Clean White
/// - Background: Soft Gray
/// - Glass: White at 15% opacity + blur
/// - Accent: Coral for alerts
class AppColors {
  AppColors._();

  // ─── Primary Sky Blue Palette ─────────────────────────
  static const Color primary = Color(0xFF0288D1);
  static const Color primaryLight = Color(0xFF4FC3F7);
  static const Color primaryDark = Color(0xFF01579B);
  static const Color primarySurface = Color(0xFFE1F5FE);

  // ─── Gradients ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
  );

  /// Fresh white → light-blue background gradient for feature pages.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),     // Pure white top
      Color(0xFFF0F8FF),     // Alice blue
      Color(0xFFE3F2FD),     // Light blue 50
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Slightly deeper variant for admin / detail pages.
  static const LinearGradient backgroundGradientDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),     // White
      Color(0xFFE8F4FD),     // Soft sky
      Color(0xFFD6EDFF),     // Light blue accent
    ],
    stops: [0.0, 0.55, 1.0],
  );

  // ─── Surfaces ─────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8ECF0);

  // ─── Text ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // ─── Semantic ─────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);
  static const Color accent = Color(0xFFFF6B6B);

  // ─── Specialised ──────────────────────────────────────
  static const Color starFilled = Color(0xFFFFB800);
  static const Color starEmpty = Color(0xFFE0E0E0);

  // Category chip colours
  static const Color chipMountain = Color(0xFF66BB6A);
  static const Color chipCulture = Color(0xFF7E57C2); // deep purple for cultural
  static const Color chipBeach = Color(0xFF29B6F6);
  static const Color chipCafe = Color(0xFFA1887F);
  static const Color chipRestaurant = Color(0xFFFF8A65);

  // ─── Glass ────────────────────────────────────────────
  static const Color glassWhite = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // ─── Shadows ──────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1A1A2E).withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF1A1A2E).withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ─── Card Border ───────────────────────────────────────
  /// Subtle card border — thin, soft blue-grey for elegant structure.
  static Border get cardBorder => Border.all(
        color: const Color(0xFFE2E8F0).withOpacity(0.6),
        width: 0.5,
      );

  /// Slightly more visible border for elevated/interactive cards.
  static Border get cardBorderStrong => Border.all(
        color: const Color(0xFFCBD5E1).withOpacity(0.5),
        width: 0.8,
      );
}
