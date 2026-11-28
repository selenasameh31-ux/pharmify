import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:pharma_orders/core/theme/app_theme.dart';

/// لوجو Pharmify مرسوم بالكود (CustomPaint) من غير أي صورة:
/// مربع متدرج + كبسولة (الدوا) + سهم طالع (المبيعات).
class PharmifyLogo extends StatelessWidget {
  const PharmifyLogo({super.key, this.size = 96, this.shadow = true});

  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .25),
                  blurRadius: size * .3,
                  offset: Offset(0, size * .1),
                ),
              ]
            : null,
      ),
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    final bg = RRect.fromRectAndRadius(rect, Radius.circular(s * .26));

    // الخلفية المتدرجة
    canvas.drawRRect(
      bg,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Brand.tealLight, Brand.tealDark],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipRRect(bg);

    // لمعة خفيفة
    canvas.drawCircle(Offset(s * .15, s * .1), s * .55,
        Paint()..color = Colors.white.withValues(alpha: .06));

    // الكبسولة (مايلة 45 درجة): نص أبيض ونص كهرماني
    canvas.save();
    canvas.translate(s * .5, s * .536);
    canvas.rotate(-math.pi / 4);
    final w = s * .393, h = s * .214;
    final pill = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Radius.circular(h / 2));
    canvas.drawRRect(pill, Paint()..color = Colors.white);
    canvas.save();
    canvas.clipRRect(pill);
    canvas.drawRect(Rect.fromLTWH(0, -h / 2, w / 2, h),
        Paint()..color = Brand.amber);
    canvas.restore();
    canvas.restore();

    // سهم المبيعات الطالع (أعلى اليمين)
    final c = Offset(s * .757, s * .25);
    final u = s / 280;
    canvas.drawCircle(c, 32 * u, Paint()..color = Colors.white);
    final arrow = Paint()
      ..color = Brand.tealDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(c.dx - 14 * u, c.dy + 14 * u)
      ..lineTo(c.dx + 14 * u, c.dy - 14 * u)
      ..moveTo(c.dx - 4 * u, c.dy - 14 * u)
      ..lineTo(c.dx + 14 * u, c.dy - 14 * u)
      ..lineTo(c.dx + 14 * u, c.dy + 4 * u);
    canvas.drawPath(path, arrow);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// كلمة Pharmify (بالإنجليزي دايمًا، من اليسار لليمين).
class PharmifyWordmark extends StatelessWidget {
  const PharmifyWordmark({super.key, this.size = 34, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: .5,
          ),
          children: const [
            TextSpan(text: 'Pharm'),
            TextSpan(text: 'ify', style: TextStyle(color: Brand.amber)),
          ],
        ),
      ),
    );
  }
}
