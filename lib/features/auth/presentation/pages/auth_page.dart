import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';

import 'package:pharma_orders/core/di/backend.dart';
import 'package:pharma_orders/features/auth/domain/failures/auth_failure.dart';
import 'package:pharma_orders/features/auth/domain/entities/app_user.dart';
import 'package:pharma_orders/core/theme/app_theme.dart';
import 'package:pharma_orders/core/theme/theme_controller.dart';
import 'package:pharma_orders/core/widgets/common.dart';
import 'package:pharma_orders/core/widgets/motion.dart';
import 'package:pharma_orders/core/widgets/pharmify_logo.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.backend,
    required this.onSignedIn,
  });

  final Backend backend;
  final ValueChanged<AppUser> onSignedIn;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signup = false;
  bool _hide = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _forgot() async {
    final t = _email.text.trim();
    if (!(t.contains('@') && t.contains('.'))) {
      setState(() => _error = tr('اكتب الإيميل الأول وبعدين دوس "نسيت الباسورد"', 'Enter your email first, then tap "Forgot password"'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.backend.sendPasswordReset(t);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('بعتنا لينك تغيير الباسورد على $t (شوف الـ Spam كمان)', 'We sent a password reset link to $t (check Spam too)'))));
      }
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = tr('حصلت مشكلة، جرّب تاني', 'Something went wrong, try again'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await widget.backend.signInWithGoogle();
      if (mounted) widget.onSignedIn(user);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = tr('حصلت مشكلة، جرّب تاني', 'Something went wrong, try again'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = _signup
          ? await widget.backend.signUp(_name.text, _email.text, _password.text)
          : await widget.backend.signIn(_email.text, _password.text);
      if (mounted) widget.onSignedIn(user);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = tr('حصلت مشكلة، جرّب تاني', 'Something went wrong, try again'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: kTealGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 40, 24, 36),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      tooltip: context.isDark ? tr('الوضع النهاري', 'Light mode') : tr('الوضع الليلي', 'Dark mode'),
                      color: Colors.white,
                      icon: Icon(context.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded),
                      onPressed: () => themeController.toggle(context.isDark),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: .6, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (context, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: const PharmifyLogo(size: 88),
                  ),
                  const SizedBox(height: 16),
                  const PharmifyWordmark(size: 34),
                  const SizedBox(height: 6),
                  Text(tr('سجّل طلبيات الدكاترة في ثواني', 'Log doctor orders in seconds'),
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FadeSlideIn(
                    child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(value: false, label: Text(tr('تسجيل الدخول', 'Sign in'))),
                            ButtonSegment(value: true, label: Text(tr('حساب جديد', 'New account'))),
                          ],
                          selected: {_signup},
                          onSelectionChanged: (s) => setState(() {
                            _signup = s.first;
                            _error = null;
                          }),
                        ),
                        const SizedBox(height: 20),
                        if (_signup) ...[
                          TextFormField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: tr('الاسم', 'Name'),
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr('اكتب اسمك', 'Enter your name')
                                : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: tr('الإيميل', 'Email'),
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            return (t.contains('@') && t.contains('.'))
                                ? null
                                : tr('اكتب إيميل صحيح', 'Enter a valid email');
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: _hide,
                          textDirection: TextDirection.ltr,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: tr('الباسورد', 'Password'),
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_hide
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _hide = !_hide),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? tr('الباسورد 6 حروف أو أرقام على الأقل', 'Password must be at least 6 characters')
                              : null,
                        ),
                        if (!_signup)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: _busy ? null : _forgot,
                              child: Text(tr('نسيت الباسورد؟', 'Forgot password?')),
                            ),
                          ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(_error!,
                                style: TextStyle(color: scheme.onErrorContainer)),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _busy ? null : _submit,
                          child: _busy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5))
                              : Text(_signup ? tr('إنشاء الحساب', 'Create account') : tr('دخول', 'Sign in')),
                        ),
                        const SizedBox(height: 16),
                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(tr('أو', 'or'),
                                style: TextStyle(color: scheme.outline)),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _google,
                          icon: const Text('G',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4285F4))),
                          label: Text(tr('الدخول بحساب جوجل', 'Continue with Google')),
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52)),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
