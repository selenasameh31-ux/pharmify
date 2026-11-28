import 'package:material_ui/material_ui.dart';

/// بيظهر العنصر بحركة: شفافية + انزلاق خفيف لفوق، وبيتأخر حسب ترتيبه [index]
/// فالعناصر تدخل واحد ورا التاني (staggered animation).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 24,
  });

  final Widget child;
  final int index;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 8)) * 60; // ms
    const total = 450;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total + delay),
      curve: Interval(delay / (total + delay), 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * offset), child: child),
      ),
      child: child,
    );
  }
}

/// رقم بيعدّ من 0 للقيمة الحقيقية (count-up).
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.builder});

  final double value;
  final Widget Function(BuildContext context, double current) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => builder(context, v),
    );
  }
}
