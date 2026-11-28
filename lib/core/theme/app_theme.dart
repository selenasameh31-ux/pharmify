import 'package:material_ui/material_ui.dart';

/// ألوان Pharmify.
class Brand {
  static const teal = Color(0xFF0B7A75);
  static const tealLight = Color(0xFF14A39A);
  static const tealDark = Color(0xFF064E4B);
  static const amber = Color(0xFFFFB02E);
  static const background = Color(0xFFF3F8F8);

  // الوضع الليلي
  static const darkBackground = Color(0xFF0D1615);
  static const darkCard = Color(0xFF16221F);
  static const darkNav = Color(0xFF111B1A);
}

/// اختصارات ألوان بتتغير مع الوضع (ليلي/نهاري).
extension BrandContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get warnBg => isDark ? const Color(0xFF3A2D12) : const Color(0xFFFFF3D6);
  Color get warnFg => isDark ? const Color(0xFFFFD98A) : const Color(0xFF5C3B00);
  Color get warnIcon => isDark ? const Color(0xFFFFB02E) : const Color(0xFF8A5A00);
}

/// الثيم الكامل للتطبيق (Material 3) في مكان واحد.
ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final dark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(seedColor: Brand.teal, brightness: brightness);
  final scheme = dark
      ? base.copyWith(
          primary: const Color(0xFF4FD1C5),
          onPrimary: const Color(0xFF00201E),
          surface: Brand.darkBackground,
          surfaceContainerHighest: Brand.darkCard,
        )
      : base;
  final cardColor = dark ? Brand.darkCard : Colors.white;
  final shape20 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Tajawal',
    scaffoldBackgroundColor: dark ? Brand.darkBackground : Brand.background,
    // انتقال ناعم بين الشاشات على كل المنصات
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    }),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Brand.teal.withValues(alpha: .25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .35)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: dark ? const Color(0xFF4FD1C5) : Brand.teal, width: 1.8),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
            fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.bold),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Brand.teal,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: shape20,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? Brand.darkNav : Colors.white,
      elevation: 8,
      shadowColor: Colors.black,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
            fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? const Color(0xFF24413E) : Brand.tealDark,
      contentTextStyle:
          const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
  );
}
