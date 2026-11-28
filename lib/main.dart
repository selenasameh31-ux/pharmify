import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pharma_orders/app/pharma_app.dart';
import 'package:pharma_orders/core/di/injection.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:pharma_orders/core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  themeController.load(prefs);
  lang.load(prefs);

  // حقن الاعتماديات: بيبني مصادر البيانات والمستودعات وحالات الاستخدام.
  try {
    final backend = await buildBackend(prefs);
    runApp(PharmaOrdersApp(backend: backend));
  } catch (e) {
    // لو التهيئة فشلت لأي سبب، نظهر رسالة مفهومة بدل ما التطبيق يعلق على الشاشة السوداء.
    runApp(_StartupErrorApp(error: e));
  }
}


/// شاشة خطأ بسيطة لو تهيئة التطبيق فشلت قبل runApp الأساسي.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'حصلت مشكلة في تشغيل التطبيق\nSomething went wrong starting the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اتأكد من النت وافتح التطبيق تاني\nCheck your connection and reopen the app',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
