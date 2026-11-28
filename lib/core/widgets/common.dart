import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:material_ui/material_ui.dart';

import 'package:pharma_orders/core/theme/app_theme.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:pharma_orders/core/theme/theme_controller.dart';


/// أرقام لاتينية دايمًا (الأرقام العربي-الهندي بتبوظ شكل الساعة 1:04 وبتتلخبط مع باقي الأرقام).
String latinDigits(String s) => s.replaceAllMapped(
    RegExp('[\u0660-\u0669]'), (m) => '${m[0]!.codeUnitAt(0) - 0x0660}');

String formatDay(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return tr('النهارده', 'Today');
  if (diff == 1) return tr('امبارح', 'Yesterday');
  return latinDigits(DateFormat('EEEE d MMMM', lang.code).format(d));
}

String formatTime(DateTime d) => latinDigits(DateFormat('h:mm a', lang.code).format(d));
String formatFull(DateTime d) => latinDigits(DateFormat('EEEE d MMMM y - h:mm a', lang.code).format(d));

const kTealGradient = LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [Color(0xFF0B7A75), Color(0xFF14A39A)],
);

/// دايرة فيها أول حرف من الاسم (بعد تجاهل "د.").
class InitialAvatar extends StatelessWidget {
  const InitialAvatar(this.name, {super.key, this.size = 46});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clean = name.replaceFirst(RegExp(r'^د\.?\s*'), '').trim();
    final letter = clean.isEmpty ? '؟' : clean.characters.first;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * .42,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: .6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

Future<bool> confirmDelete(BuildContext context, String message) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_outline_rounded, size: 32),
      title: Text(tr('تأكيد الحذف', 'Confirm delete')),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('إلغاء', 'Cancel'))),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(90, 44),
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr('حذف', 'Delete')),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
}

final _moneyFmt = NumberFormat('#,##0', 'en');
String formatMoney(num v) => '${_moneyFmt.format(v.round())} ${tr('ج.م', 'EGP')}';
String formatNum(num v) => _moneyFmt.format(v.round());

/// هيدر متدرج مشترك لكل الشاشات: عنوان + سطر فرعي + زرار الحساب.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: kTealGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // دواير ديكور شفافة
          Positioned(
            top: -60,
            left: -40,
            child: _Bubble(170, .07),
          ),
          Positioned(
            bottom: -70,
            right: -30,
            child: _Bubble(150, .06),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 14, 12, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                    ),
                    ?trailing,
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 8),
                    child: child,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.size, this.alpha);
  final double size, alpha;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}

/// قايمة الحساب: الاسم والدور وتسجيل الخروج.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key, required this.name, required this.email,
      required this.isAdmin, required this.onSignOut});

  final String name, email;
  final bool isAdmin;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: tr('الحساب', 'Account'),
      icon: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 30),
      onSelected: (v) {
        if (v == 'theme') {
          themeController.toggle(context.isDark);
        } else if (v == 'lang') {
          lang.toggle();
        } else {
          onSignOut();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(isAdmin ? tr('أدمن (رئيس المبيعات)', 'Admin (sales head)') : tr('مندوب', 'Sales rep'),
                  style: const TextStyle(fontSize: 12)),
              Text(email,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'theme',
          child: Row(children: [
            Icon(context.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded, size: 20),
            const SizedBox(width: 10),
            Text(context.isDark ? tr('الوضع النهاري', 'Light mode') : tr('الوضع الليلي', 'Dark mode')),
          ]),
        ),
        PopupMenuItem(
          value: 'lang',
          child: Row(children: [
            const Icon(Icons.translate_rounded, size: 20),
            const SizedBox(width: 10),
            Text(lang.isAr ? 'English' : 'العربية'),
          ]),
        ),
        PopupMenuItem(
          value: 'out',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 10),
            Text(tr('تسجيل الخروج', 'Sign out')),
          ]),
        ),
      ],
    );
  }
}
