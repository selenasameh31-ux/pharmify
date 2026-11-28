import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بيحفظ اختيار الوضع الليلي/النهاري على الجهاز (SharedPreferences)
/// وبيبلّغ التطبيق يتغيّر فورًا.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode_v1';

  ThemeMode mode = ThemeMode.system;
  SharedPreferences? _prefs;

  void load(SharedPreferences prefs) {
    _prefs = prefs;
    switch (prefs.getString(_key)) {
      case 'dark':
        mode = ThemeMode.dark;
      case 'light':
        mode = ThemeMode.light;
      default:
        mode = ThemeMode.system;
    }
  }

  /// [isDarkNow] هو الوضع الشغال حاليًا (حتى لو كان تلقائي من الجهاز).
  void toggle(bool isDarkNow) {
    mode = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    _prefs?.setString(_key, isDarkNow ? 'light' : 'dark');
    notifyListeners();
  }
}

final themeController = ThemeController();
