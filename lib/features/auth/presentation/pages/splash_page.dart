import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';

import 'package:pharma_orders/core/theme/app_theme.dart';
import 'package:pharma_orders/core/widgets/pharmify_logo.dart';

/// شاشة البداية: اللوجو بيكبر بحركة مرنة، الاسم يظهر، وبعدها الشعار الفرعي.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..forward();

  // كل جزء له توقيت (Interval) جوا نفس الأنيميشن
  late final Animation<double> _logoScale = CurvedAnimation(
      parent: _c, curve: const Interval(0, .45, curve: Curves.elasticOut));
  late final Animation<double> _logoFade = CurvedAnimation(
      parent: _c, curve: const Interval(0, .2, curve: Curves.easeOut));
  late final Animation<double> _nameFade = CurvedAnimation(
      parent: _c, curve: const Interval(.35, .65, curve: Curves.easeOut));
  late final Animation<double> _tagFade = CurvedAnimation(
      parent: _c, curve: const Interval(.55, .85, curve: Curves.easeOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Brand.tealLight, Brand.teal, Brand.tealDark],
          ),
        ),
        child: Stack(
          children: [
            // دواير ديكور
            Positioned(
              top: -90,
              left: -70,
              child: _circle(260, .06),
            ),
            Positioned(
              bottom: -110,
              right: -80,
              child: _circle(320, .07),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: .4 + .6 * _logoScale.value,
                        child: const PharmifyLogo(size: 128),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Opacity(
                      opacity: _nameFade.value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _nameFade.value) * 14),
                        child: const PharmifyWordmark(size: 44),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: _tagFade.value,
                      child: Text(
                        tr('طلبيات الدكاترة في ثواني', 'Doctor orders in seconds'),
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 130,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      color: Brand.amber,
                      backgroundColor: Colors.white24,
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

  Widget _circle(double d, double a) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: a),
        ),
      );
}
