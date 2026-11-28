import 'package:material_ui/material_ui.dart';

import 'package:pharma_orders/core/di/backend.dart';
import 'package:pharma_orders/features/auth/domain/entities/app_user.dart';
import 'package:pharma_orders/features/auth/presentation/pages/auth_page.dart';
import 'package:pharma_orders/features/auth/presentation/pages/splash_page.dart';
import 'package:pharma_orders/features/home/presentation/pages/home_shell.dart';
import 'app_store.dart';

/// بيقرر نعرض شاشة الدخول ولا التطبيق نفسه حسب حالة المستخدم.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.backend});

  final Backend backend;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _loading = true;
  AppStore? _store;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    AppUser? user;
    // السبلاش بتفضل ثانيتين على الأقل عشان الحركة تكمل
    final minSplash = Future<void>.delayed(const Duration(milliseconds: 2300));
    try {
      user = await widget.backend.restoreSession();
    } catch (_) {
      user = null;
    }
    await minSplash;
    if (!mounted) return;
    if (user != null) _enter(user);
    setState(() => _loading = false);
  }

  void _enter(AppUser user) {
    final store = AppStore(widget.backend, user);
    store.start();
    _store = store;
  }

  Future<void> _signOut() async {
    await widget.backend.signOut();
    _store?.dispose();
    setState(() => _store = null);
  }

  @override
  void dispose() {
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    final Widget screen;
    if (_loading) {
      screen = const SplashPage(key: ValueKey('splash'));
    } else if (store == null) {
      screen = AuthPage(
        key: const ValueKey('auth'),
        backend: widget.backend,
        onSignedIn: (user) => setState(() => _enter(user)),
      );
    } else {
      screen = HomeShell(
        key: ValueKey(store.user.uid),
        store: store,
        isDemo: widget.backend.isDemo,
        onSignOut: _signOut,
      );
    }
    // انتقال بالتلاشي بين السبلاش والدخول والتطبيق
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOut,
      child: screen,
    );
  }
}
