import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;

import 'package:pharma_orders/core/di/backend.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:pharma_orders/core/theme/app_theme.dart';
import 'package:pharma_orders/core/theme/theme_controller.dart';
import 'app_root.dart';

/// جذر التطبيق: الثيم واللغة والاتجاه.
class PharmaOrdersApp extends StatelessWidget {
  const PharmaOrdersApp({super.key, required this.backend});

  final Backend backend;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeController, lang]),
      builder: (context, _) => MaterialApp(
      title: 'Pharmify',
      debugShowCheckedModeBanner: false,
      locale: lang.locale,
      supportedLocales: const [Locale('ar', 'EG'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeController.mode,
      builder: (context, child) => Directionality(
        textDirection: lang.dir,
        child: child!,
      ),
      home: AppRoot(backend: backend),
    ));
  }
}
