import 'package:flutter/material.dart';

/// MEMOtrip Design Tokens — Spacing, Sizing & Border Radius
class AppSpacing {
  AppSpacing._();

  // ─── Spacing Scale ────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // ─── Radius ───────────────────────────────────────────
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusCard = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusFull = 100.0;

  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusCard =>
      BorderRadius.circular(radiusCard);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusFull =>
      BorderRadius.circular(radiusFull);

  // ─── Component Sizes ──────────────────────────────────
  static const double navBarHeight = 72.0;
  static const double heroImageHeight = 300.0;
  static const double destinationCardHeight = 220.0;
  static const double sensorCardWidth = 130.0;
  static const double categoryIconSize = 44.0;
  static const double bottomSafeArea = 120.0;

  // ─── Padding Presets ──────────────────────────────────
  static const EdgeInsets paddingSection =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingCard = EdgeInsets.all(base);
}
