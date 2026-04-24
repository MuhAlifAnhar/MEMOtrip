import 'package:flutter/material.dart';

/// Custom page transition utilities for smooth navigation.
class PageTransitions {
  PageTransitions._();

  /// Slide + Fade transition from right (default for push navigations).
  static Route<T> slideUp<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curvedAnim),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curvedAnim),
            child: child,
          ),
        );
      },
    );
  }

  /// Shared-axis-like horizontal slide transition.
  static Route<T> slideRight<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.25, 0),
            end: Offset.zero,
          ).animate(curvedAnim),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curvedAnim),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale + Fade transition (for modals or detail pages).
  static Route<T> scaleFade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnim),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Named route transition builder for MaterialApp.
  static Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) get defaultTransitionBuilder {
    return (context, animation, secondaryAnimation, child) {
      final curvedAnim = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).animate(curvedAnim),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curvedAnim),
          child: child,
        ),
      );
    };
  }
}
