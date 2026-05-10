// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../services/supabase_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZennColors.background,
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Logo + açıklama
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/icons/icon.png', width: 80, height: 80),
            ),
            const SizedBox(height: 16),
            const Text('ZeNN Sudoku', style: ZennTextStyles.headline2,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Giriş yap, istatistiklerini kaydet\nve elmas kazan.',
              style: ZennTextStyles.caption.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Google butonu
            _GoogleSignInButton(onSuccess: () {
              ref.invalidate(profileProvider);
              ref.invalidate(completionStatsProvider);
              context.pop();
            }),

            const SizedBox(height: 20),

            // Ayırıcı
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('veya', style: ZennTextStyles.caption),
              ),
              const Expanded(child: Divider()),
            ]),

            const SizedBox(height: 20),

            // E-posta sekmeleri
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ZennColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                tabAlignment: TabAlignment.fill,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: ZennColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: ZennColors.textMid,
                labelStyle: const TextStyle(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Giriş Yap'),
                  Tab(text: 'Kayıt Ol'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _SignInForm(onSuccess: () {
                  ref.invalidate(profileProvider);
                  ref.invalidate(completionStatsProvider);
                  context.pop();
                  // daily screen açıksa yenile
                  context.push(AppConstants.routeDaily);
                }),
                  _SignUpForm(onSuccess: () {
                    ref.invalidate(profileProvider);
                    ref.invalidate(completionStatsProvider);
                    context.pop();
                  }),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Google Giriş Butonu ──────────────────────────────────────────────────────

class _GoogleSignInButton extends StatefulWidget {
  final VoidCallback onSuccess;
  const _GoogleSignInButton({required this.onSuccess});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _signIn,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ZennColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZennColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: _loading
            ? const Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2,
                    color: ZennColors.primary)))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata, size: 24, color: ZennColors.textDark),
                  SizedBox(width: 10),
                  Text('Google ile Giriş Yap',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                          fontWeight: FontWeight.w600, color: ZennColors.textDark)),
                ],
              ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await SupabaseService.instance.signInWithGoogle();
      widget.onSuccess();
    } catch (e) {
       print('GOOGLE ERROR: $e');
      if (!mounted) return;
      _showError(context, 'Google girişi başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Giriş Formu ─────────────────────────────────────────────────────────────

class _SignInForm extends StatefulWidget {
  final VoidCallback onSuccess;
  const _SignInForm({required this.onSuccess});

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmailField(controller: _emailCtrl),
        const SizedBox(height: 12),
        _PasswordField(
          controller: _passwordCtrl,
          obscure: _obscure,
          onToggle: () => setState(() => _obscure = !_obscure),
        ),
        const SizedBox(height: 8),
        // Şifremi unuttum
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text('Şifremi unuttum',
                style: ZennTextStyles.caption.copyWith(color: ZennColors.primary)),
          ),
        ),
        const SizedBox(height: 8),
        _SubmitButton(
          label: 'Giriş Yap',
          loading: _loading,
          onTap: _signIn,
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _showError(context, 'E-posta ve şifre gerekli');
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.instance.signInWithEmail(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      _showError(context, _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.isEmpty) {
      _showError(context, 'Önce e-posta adresini gir');
      return;
    }
    try {
      await SupabaseService.instance.resetPassword(_emailCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Şifre sıfırlama linki gönderildi'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ZennColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } catch (e) {
      if (!mounted) return;
      _showError(context, 'Gönderilemedi: $e');
    }
  }
}

// ─── Kayıt Formu ─────────────────────────────────────────────────────────────

class _SignUpForm extends StatefulWidget {
  final VoidCallback onSuccess;
  const _SignUpForm({required this.onSuccess});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _loading       = false;
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmailField(controller: _emailCtrl),
        const SizedBox(height: 12),
        _PasswordField(
          controller: _passwordCtrl,
          obscure: _obscure,
          onToggle: () => setState(() => _obscure = !_obscure),
          hint: 'Şifre (en az 6 karakter)',
        ),
        const SizedBox(height: 12),
        _PasswordField(
          controller: _confirmCtrl,
          obscure: _obscure,
          onToggle: () => setState(() => _obscure = !_obscure),
          hint: 'Şifreyi tekrar gir',
        ),
        const SizedBox(height: 20),
        _SubmitButton(
          label: 'Kayıt Ol',
          loading: _loading,
          onTap: _signUp,
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _showError(context, 'Tüm alanları doldur');
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      _showError(context, 'Şifreler eşleşmiyor');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _showError(context, 'Şifre en az 6 karakter olmalı');
      return;
    }
    setState(() => _loading = true);
    try {
      await SupabaseService.instance.signUpWithEmail(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      _showError(context, _parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Paylaşılan Alanlar ───────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('E-posta adresi', Icons.email_outlined),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String hint;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.hint = 'Şifre',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(hint, Icons.lock_outline_rounded).copyWith(
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20, color: ZennColors.textHint),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _SubmitButton(
      {required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ZennColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
            ? const Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2,
                    color: Colors.white)))
            : Text(label, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
        fontFamily: 'Inter', fontSize: 14, color: ZennColors.textHint),
    prefixIcon: Icon(icon, size: 20, color: ZennColors.textHint),
    filled: true,
    fillColor: ZennColors.surface,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ZennColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ZennColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ZennColors.primary, width: 1.5),
    ),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    backgroundColor: ZennColors.error,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  ));
}

String _parseError(String error) {
  if (error.contains('Invalid login credentials')) return 'E-posta veya şifre hatalı';
  if (error.contains('User already registered')) return 'Bu e-posta zaten kayıtlı';
  if (error.contains('Password should be')) return 'Şifre en az 6 karakter olmalı';
  if (error.contains('Unable to validate email')) return 'Geçersiz e-posta adresi';
  return error; // ← 'Bir hata oluştu' yerine direkt hatayı göster
}