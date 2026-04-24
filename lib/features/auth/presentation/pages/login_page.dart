import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/shake_widget.dart';

// ═════════════════════════════════════════════════════════════
//  Shared Error-Input Theme
// ═════════════════════════════════════════════════════════════
InputDecoration _inputDeco({
  required String hint,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(prefixIcon, size: 20),
    suffixIcon: suffixIcon,
    errorStyle: AppTypography.caption.copyWith(
      color: AppColors.error,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    ),
    errorMaxLines: 2,
    errorBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusMedium,
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppSpacing.borderRadiusMedium,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
  );
}

// ═════════════════════════════════════════════════════════════
//  Login Page
// ═════════════════════════════════════════════════════════════
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailShake = GlobalKey<ShakeWidgetState>();
  final _passShake = GlobalKey<ShakeWidgetState>();
  final _btnShake = GlobalKey<ShakeWidgetState>();
  bool _obscure = true;
  bool _loading = false;
  bool _submitted = false; // tracks whether submit was attempted

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
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutBack,
                              builder: (_, v, child) => Transform.scale(
                                  scale: 0.5 + 0.5 * v,
                                  child: Opacity(opacity: v, child: child)),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.base),
                                decoration: const BoxDecoration(
                                    color: AppColors.primarySurface,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.travel_explore_rounded,
                                    color: AppColors.primary, size: 40),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            _stagger(0, Text(AppStrings.appName,
                                style: AppTypography.displayMedium
                                    .copyWith(color: AppColors.primary))),
                            _stagger(0, Text(AppStrings.appTagline,
                                style: AppTypography.caption)),
                            const SizedBox(height: AppSpacing.xxl),

                            // Email
                            _stagger(1, ShakeWidget(
                              key: _emailShake,
                              child: TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTypography.bodyMedium,
                                validator: _validateEmail,
                                decoration: _inputDeco(
                                  hint: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.base),

                            // Password
                            _stagger(2, ShakeWidget(
                              key: _passShake,
                              child: TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: AppTypography.bodyMedium,
                                validator: _validatePassword,
                                decoration: _inputDeco(
                                  hint: 'Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      size: 20),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.sm),

                            _stagger(3, Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: Text('Lupa Password?',
                                    style: AppTypography.labelSmall
                                        .copyWith(color: AppColors.primary)),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.base),

                            // Login Button (with shake)
                            _stagger(4, ShakeWidget(
                              key: _btnShake,
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _login,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: _loading
                                        ? const SizedBox(
                                            key: ValueKey('l'),
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : const Text('Masuk',
                                            key: ValueKey('t')),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.lg),

                            // Divider
                            _stagger(5, Row(children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('atau', style: AppTypography.caption),
                              ),
                              const Expanded(child: Divider()),
                            ])),
                            const SizedBox(height: AppSpacing.lg),

                            // Google
                            _stagger(6, SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () => _showSnackbar(
                                    'Google Sign-In — Segera hadir!',
                                    AppColors.warning),
                                icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                                label: const Text('Masuk dengan Google'),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.xl),

                            // Register Link
                            _stagger(7, Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Belum punya akun? ',
                                    style: AppTypography.bodySmall),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/register'),
                                  child: Text('Daftar',
                                      style: AppTypography.labelMedium
                                          .copyWith(color: AppColors.primary)),
                                ),
                              ],
                            )),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stagger(int i, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (i * 60)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(0, 12 * (1 - v)),
        child: Opacity(opacity: v, child: ch),
      ),
      child: child,
    );
  }

  // ─── Validators ────────────────────────────────────────
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  // ─── Login ─────────────────────────────────────────────
  Future<void> _login() async {
    setState(() => _submitted = true);

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      // Shake invalid fields
      if (_validateEmail(_emailCtrl.text) != null) {
        _emailShake.currentState?.shake();
      }
      if (_validatePassword(_passCtrl.text) != null) {
        _passShake.currentState?.shake();
      }
      _btnShake.currentState?.shake();
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.signInWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackbar(AuthService.friendlyError(e), AppColors.error);
    } catch (e) {
      if (mounted) _showSnackbar('Terjadi kesalahan: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Forgot Password ──────────────────────────────────
  void _forgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
        title: Row(children: [
          const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text('Reset Password', style: AppTypography.headlineSmall),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan email untuk menerima link reset.',
                style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.base),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (ctrl.text.trim().isNotEmpty) {
                try {
                  await AuthService.sendPasswordReset(ctrl.text);
                  if (mounted) {
                    _showSnackbar('Link reset dikirim ke ${ctrl.text}',
                        AppColors.success);
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    _showSnackbar(AuthService.friendlyError(e), AppColors.error);
                  }
                }
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String msg, Color c) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: c,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
      margin: const EdgeInsets.all(AppSpacing.lg),
      duration: const Duration(seconds: 3),
    ));
  }
}

// ═════════════════════════════════════════════════════════════
//  Register Page
// ═════════════════════════════════════════════════════════════
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameShake = GlobalKey<ShakeWidgetState>();
  final _emailShake = GlobalKey<ShakeWidgetState>();
  final _passShake = GlobalKey<ShakeWidgetState>();
  final _confirmShake = GlobalKey<ShakeWidgetState>();
  final _btnShake = GlobalKey<ShakeWidgetState>();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _submitted = false;

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
    _confirmCtrl.dispose();
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
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutBack,
                              builder: (_, v, child) => Transform.scale(
                                  scale: 0.5 + 0.5 * v,
                                  child: Opacity(opacity: v, child: child)),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.base),
                                decoration: const BoxDecoration(
                                    color: AppColors.primarySurface,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.person_add_rounded,
                                    color: AppColors.primary, size: 36),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.base),
                            _stagger(0, Text('Daftar Akun',
                                style: AppTypography.displaySmall
                                    .copyWith(color: AppColors.primary))),
                            const SizedBox(height: AppSpacing.sm),
                            _stagger(0, Text('Buat akun MEMOtrip baru',
                                style: AppTypography.caption)),
                            const SizedBox(height: AppSpacing.xxl),

                            // Name
                            _stagger(1, ShakeWidget(
                              key: _nameShake,
                              child: TextFormField(
                                controller: _nameCtrl,
                                style: AppTypography.bodyMedium,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Nama wajib diisi' : null,
                                decoration: _inputDeco(
                                  hint: 'Nama Lengkap',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.base),

                            // Email
                            _stagger(2, ShakeWidget(
                              key: _emailShake,
                              child: TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTypography.bodyMedium,
                                validator: _validateEmail,
                                decoration: _inputDeco(
                                  hint: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.base),

                            // Password
                            _stagger(3, ShakeWidget(
                              key: _passShake,
                              child: TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: AppTypography.bodyMedium,
                                validator: _validatePassword,
                                decoration: _inputDeco(
                                  hint: 'Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded, size: 20),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.base),

                            // Confirm Password
                            _stagger(4, ShakeWidget(
                              key: _confirmShake,
                              child: TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                style: AppTypography.bodyMedium,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Konfirmasi password wajib diisi';
                                  }
                                  if (v != _passCtrl.text) {
                                    return 'Password tidak sama';
                                  }
                                  return null;
                                },
                                decoration: _inputDeco(
                                  hint: 'Konfirmasi Password',
                                  prefixIcon: Icons.lock_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      size: 20),
                                    onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.xl),

                            // Register Button (with shake)
                            _stagger(5, ShakeWidget(
                              key: _btnShake,
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _register,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: _loading
                                        ? const SizedBox(
                                            key: ValueKey('l'),
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : const Text('Daftar',
                                            key: ValueKey('t')),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(height: AppSpacing.lg),

                            // Login Link
                            _stagger(6, Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sudah punya akun? ',
                                    style: AppTypography.bodySmall),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text('Masuk',
                                      style: AppTypography.labelMedium
                                          .copyWith(color: AppColors.primary)),
                                ),
                              ],
                            )),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stagger(int i, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (i * 60)),
      curve: Curves.easeOutCubic,
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(0, 12 * (1 - v)),
        child: Opacity(opacity: v, child: ch),
      ),
      child: child,
    );
  }

  // ─── Validators ────────────────────────────────────────
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  // ─── Register ──────────────────────────────────────────
  Future<void> _register() async {
    setState(() => _submitted = true);

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      // Shake each invalid field
      if (_nameCtrl.text.trim().isEmpty) _nameShake.currentState?.shake();
      if (_validateEmail(_emailCtrl.text) != null) _emailShake.currentState?.shake();
      if (_validatePassword(_passCtrl.text) != null) _passShake.currentState?.shake();
      if (_confirmCtrl.text.isEmpty || _confirmCtrl.text != _passCtrl.text) {
        _confirmShake.currentState?.shake();
      }
      _btnShake.currentState?.shake();
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.registerWithEmail(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackbar(AuthService.friendlyError(e), AppColors.error);
    } catch (e) {
      if (mounted) _showSnackbar('Terjadi kesalahan: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackbar(String msg, Color c) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: c,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
      margin: const EdgeInsets.all(AppSpacing.lg),
      duration: const Duration(seconds: 3),
    ));
  }
}
