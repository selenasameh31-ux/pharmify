

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// اللغة: الافتراضي عربي دايمًا (طلب المستخدمة)، وزرار في قايمة الحساب
/// بيغيّرها للإنجليزي ويحفظ الاختيار.
class LangController extends ChangeNotifier {
  static const _key = 'lang_v1';

  SharedPreferences? _prefs;
  String? _override; // 'ar' | 'en' | null = الافتراضي (عربي)

  void load(SharedPreferences prefs) {
    _prefs = prefs;
    final v = prefs.getString(_key);
    _override = (v == 'ar' || v == 'en') ? v : null;
  }

  String get code => _override ?? 'ar';
  bool get isAr => code == 'ar';
  Locale get locale => isAr ? const Locale('ar', 'EG') : const Locale('en');
  TextDirection get dir => isAr ? TextDirection.rtl : TextDirection.ltr;

  void toggle() {
    _override = isAr ? 'en' : 'ar';
    _prefs?.setString(_key, _override!);
    notifyListeners();
    // إعادة بناء كل الشاشات الشغالة من غير ما نرجّع المستخدم للرئيسية
    // (عشان لو في نص طلبية ما يضيعش اللي كتبه).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void rebuild(Element e) {
        e.markNeedsBuild();
        e.visitChildren(rebuild);
      }

      WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
    });
  }
}

final lang = LangController();

/// ترجمة: النص العربي أولًا ثم الإنجليزي.
String tr(String ar, String en) => lang.isAr ? ar : en;
