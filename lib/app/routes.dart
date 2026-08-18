import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/admin/presentation/pages/admin_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/role_provider.dart';
import '../core/widgets/access_denied_page.dart';
/// Named route definitions for MEMOtrip.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        admin: (_) => const _AdminGuard(),
      };
}

/// Route guard widget that checks admin role before showing AdminShell.
class _AdminGuard extends ConsumerWidget {
  const _AdminGuard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (isAdmin) {
      return const AdminShell();
    }
    return const AccessDeniedPage();
  }
}
