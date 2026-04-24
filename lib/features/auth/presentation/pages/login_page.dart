import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppSpacing.borderRadiusCard,
                        boxShadow: AppColors.elevatedShadow),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo — scale entrance
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutBack,
                            builder: (_, v, child) => Transform.scale(
                                scale: 0.5 + 0.5 * v,
                                child:
                                    Opacity(opacity: v, child: child)),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(AppSpacing.base),
                              decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle),
                              child: const Icon(
                                  Icons.travel_explore_rounded,
                                  color: AppColors.primary,
                                  size: 40),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          _stagger(
                            0,
                            Text(AppStrings.appName,
                                style: AppTypography.displayMedium
                                    .copyWith(color: AppColors.primary)),
                          ),
                          _stagger(
                            0,
                            Text(AppStrings.appTagline,
                                style: AppTypography.caption),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          // Email
                          _stagger(
                            1,
                            TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTypography.bodyMedium,
                                decoration: const InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: Icon(
                                        Icons.email_outlined,
                                        size: 20))),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          // Password
                          _stagger(
                            2,
                            TextField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: AppTypography.bodyMedium,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 20),
                                    suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscure
                                                ? Icons
                                                    .visibility_off_rounded
                                                : Icons
                                                    .visibility_rounded,
                                            size: 20),
                                        onPressed: () => setState(
                                            () => _obscure =
                                                !_obscure)))),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _stagger(
                            3,
                            Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                    onPressed: () {},
                                    child: Text('Lupa Password?',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                                color:
                                                    AppColors.primary)))),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          // Login Button
                          _stagger(
                            4,
                            SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _login,
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    child: _loading
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white))
                                        : const Text('Masuk',
                                            key: ValueKey('text')),
                                  ),
                                )),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Divider
                          _stagger(
                            5,
                            Row(children: [
                              const Expanded(child: Divider()),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text('atau',
                                      style: AppTypography.caption)),
                              const Expanded(child: Divider()),
                            ]),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Google Sign In
                          _stagger(
                            6,
                            SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                        Icons.g_mobiledata_rounded,
                                        size: 24),
                                    label: const Text(
                                        'Masuk dengan Google'))),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // Register Link
                          _stagger(
                            7,
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text('Belum punya akun? ',
                                      style: AppTypography.bodySmall),
                                  GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                          context, '/register'),
                                      child: Text('Daftar',
                                          style: AppTypography.labelMedium
                                              .copyWith(
                                                  color: AppColors
                                                      .primary))),
                                ]),
                          ),
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stagger(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(0, 12 * (1 - v)),
        child: Opacity(opacity: v, child: ch),
      ),
      child: child,
    );
  }

  void _login() {
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
    });
  }
}

/// Register Page — Accessed via /register route.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppSpacing.borderRadiusCard,
                        boxShadow: AppColors.elevatedShadow),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _stagger(
                              0,
                              Text('Daftar Akun',
                                  style: AppTypography.displaySmall)),
                          const SizedBox(height: AppSpacing.sm),
                          _stagger(
                              0,
                              Text('Buat akun MEMOtrip baru',
                                  style: AppTypography.caption)),
                          const SizedBox(height: AppSpacing.xxl),
                          _stagger(
                            1,
                            TextField(
                                controller: _nameCtrl,
                                style: AppTypography.bodyMedium,
                                decoration: const InputDecoration(
                                    hintText: 'Nama Lengkap',
                                    prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        size: 20))),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          _stagger(
                            2,
                            TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTypography.bodyMedium,
                                decoration: const InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: Icon(
                                        Icons.email_outlined,
                                        size: 20))),
                          ),
                          const SizedBox(height: AppSpacing.base),
                          _stagger(
                            3,
                            TextField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: AppTypography.bodyMedium,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 20),
                                    suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscure
                                                ? Icons
                                                    .visibility_off_rounded
                                                : Icons
                                                    .visibility_rounded,
                                            size: 20),
                                        onPressed: () => setState(
                                            () => _obscure =
                                                !_obscure)))),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _stagger(
                            4,
                            SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _register,
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    child: _loading
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white))
                                        : const Text('Daftar',
                                            key: ValueKey('text')),
                                  ),
                                )),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _stagger(
                            5,
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text('Sudah punya akun? ',
                                      style: AppTypography.bodySmall),
                                  GestureDetector(
                                      onTap: () =>
                                          Navigator.pop(context),
                                      child: Text('Masuk',
                                          style: AppTypography.labelMedium
                                              .copyWith(
                                                  color: AppColors
                                                      .primary))),
                                ]),
                          ),
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stagger(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(0, 12 * (1 - v)),
        child: Opacity(opacity: v, child: ch),
      ),
      child: child,
    );
  }

  void _register() {
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
    });
  }
}
