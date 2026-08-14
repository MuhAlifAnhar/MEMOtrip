import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/shake_widget.dart';

// ═════════════════════════════════════════════════════════════
//  Custom Wave Clipper for Bottom Wave
// ═════════════════════════════════════════════════════════════
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 120);

    final firstControlPoint = Offset(size.width * 0.5, size.height - 185);
    final firstEndPoint = Offset(size.width, size.height - 100);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ═════════════════════════════════════════════════════════════
//  Shared Outlined Border Input Theme
// ═════════════════════════════════════════════════════════════
InputDecoration _inputDeco({
  required String labelText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle:
        AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3F64D4), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    errorStyle: AppTypography.caption.copyWith(
      color: AppColors.error,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    ),
    errorMaxLines: 2,
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Widget _buildSocialButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── Background Decorative Shapes ───────────────────
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -100,
            top: size.height * 0.35,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -100,
            bottom: size.height * 0.15,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3F64D4),
                      Color(0xFF1E3A8A),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ─── Main Form Content ──────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 32, right: 32, top: 16, bottom: 85),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutBack,
                            builder: (_, v, child) => Transform.scale(
                              scale: 0.5 + 0.5 * v,
                              child: Opacity(
                                  opacity: v.clamp(0.0, 1.0), child: child),
                            ),
                            child: Image.asset(
                              'assets/images/logo_memotrip.png',
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _stagger(
                              1,
                              ShakeWidget(
                                key: _emailShake,
                                child: TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: AppTypography.bodyMedium,
                                  validator: _validateEmail,
                                  decoration: _inputDeco(labelText: 'Email'),
                                ),
                              )),
                          const SizedBox(height: 16),
                          _stagger(
                              2,
                              ShakeWidget(
                                key: _passShake,
                                child: TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  style: AppTypography.bodyMedium,
                                  validator: _validatePassword,
                                  decoration: _inputDeco(
                                    labelText: 'Kata Sandi',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 16),
                          _stagger(
                              3,
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text:
                                            'Dengan melanjutkan, Anda memberikan izin untuk penggunaan data sesuai ',
                                      ),
                                      TextSpan(
                                        text: 'kebijakan kami.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          const SizedBox(height: 24),
                          _stagger(
                              4,
                              ShakeWidget(
                                key: _btnShake,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3F64D4),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: _loading
                                          ? const SizedBox(
                                              key: ValueKey('l'),
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Masuk',
                                              key: ValueKey('t'),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 24),
                          _stagger(
                              5,
                              Text(
                                'Atau masuk dengan',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              )),
                          const SizedBox(height: 16),
                          _stagger(
                              6,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    child: const Icon(Icons.facebook,
                                        color: Color(0xFF1877F2), size: 28),
                                    onTap: () => _showSnackbar(
                                      'Facebook Masuk — Segera hadir!',
                                      AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildSocialButton(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.red,
                                          Colors.yellow,
                                          Colors.green
                                        ],
                                        stops: [0.0, 0.3, 0.6, 1.0],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'G',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    onTap: () => _showSnackbar(
                                      'Google Masuk — Segera hadir!',
                                      AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildSocialButton(
                                    child: const Icon(Icons.apple,
                                        color: Colors.black, size: 28),
                                    onTap: () => _showSnackbar(
                                      'Apple Masuk — Segera hadir!',
                                      AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildSocialButton(
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0077B5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'in',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'Arial',
                                        ),
                                      ),
                                    ),
                                    onTap: () => _showSnackbar(
                                      'LinkedIn Masuk — Segera hadir!',
                                      AppColors.warning,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: _stagger(
                7,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun? ",
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white.withOpacity(0.85)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
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

  Future<void> _login() async {
    setState(() => _submitted = true);

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
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

  void _showSnackbar(String msg, Color c) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: c,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── Background Decorative Shapes ───────────────────
          // Top Right Circle
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Middle Left Circle
          Positioned(
            left: -100,
            top: size.height * 0.35,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom Right Circle
          Positioned(
            right: -100,
            bottom: size.height * 0.15,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom Wave Curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3F64D4),
                      Color(0xFF1E3A8A),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ─── Main Form Content ──────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 32, right: 32, top: 16, bottom: 85),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mascot Logo
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutBack,
                            builder: (_, v, child) => Transform.scale(
                              scale: 0.5 + 0.5 * v,
                              child: Opacity(
                                  opacity: v.clamp(0.0, 1.0), child: child),
                            ),
                            child: Image.asset(
                              'assets/images/logo_memotrip.png',
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name field
                          _stagger(
                              1,
                              ShakeWidget(
                                key: _nameShake,
                                child: TextFormField(
                                  controller: _nameCtrl,
                                  style: AppTypography.bodyMedium,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Nama wajib diisi'
                                          : null,
                                  decoration:
                                      _inputDeco(labelText: 'Nama Lengkap'),
                                ),
                              )),
                          const SizedBox(height: 16),

                          // Email field
                          _stagger(
                              2,
                              ShakeWidget(
                                key: _emailShake,
                                child: TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: AppTypography.bodyMedium,
                                  validator: _validateEmail,
                                  decoration: _inputDeco(labelText: 'Email'),
                                ),
                              )),
                          const SizedBox(height: 16),

                          // Password field
                          _stagger(
                              3,
                              ShakeWidget(
                                key: _passShake,
                                child: TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  style: AppTypography.bodyMedium,
                                  validator: _validatePassword,
                                  decoration: _inputDeco(
                                    labelText: 'Kata Sandi',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 16),

                          // Confirm Password field
                          _stagger(
                              4,
                              ShakeWidget(
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
                                    labelText: 'Konfirmasi Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscureConfirm = !_obscureConfirm),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 24),

                          // Register Button
                          _stagger(
                              5,
                              ShakeWidget(
                                key: _btnShake,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3F64D4),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: _loading
                                          ? const SizedBox(
                                              key: ValueKey('l'),
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Daftar',
                                              key: ValueKey('t'),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Already have an account? Login (Absolutely Positioned at the bottom inside the dark blue wave)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: _stagger(
                6,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white.withOpacity(0.85)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
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
      if (_nameCtrl.text.trim().isEmpty) _nameShake.currentState?.shake();
      if (_validateEmail(_emailCtrl.text) != null)
        _emailShake.currentState?.shake();
      if (_validatePassword(_passCtrl.text) != null)
        _passShake.currentState?.shake();
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
      shape:
          RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
      margin: const EdgeInsets.all(AppSpacing.lg),
      duration: const Duration(seconds: 3),
    ));
  }
}
