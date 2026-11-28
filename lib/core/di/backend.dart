import 'package:pharma_orders/features/auth/domain/usecases/restore_session.dart';
import 'package:pharma_orders/features/auth/domain/usecases/send_password_reset.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_in.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_out.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_up.dart';
import 'package:pharma_orders/features/catalog/domain/usecases/seed_catalog_if_empty.dart';
import 'package:pharma_orders/features/doctors/domain/usecases/delete_doctor.dart';
import 'package:pharma_orders/features/doctors/domain/usecases/save_doctor.dart';
import 'package:pharma_orders/features/doctors/domain/usecases/watch_doctors.dart';
import 'package:pharma_orders/features/medicines/domain/usecases/delete_medicine.dart';
import 'package:pharma_orders/features/medicines/domain/usecases/save_medicine.dart';
import 'package:pharma_orders/features/medicines/domain/usecases/watch_medicines.dart';
import 'package:pharma_orders/features/orders/domain/usecases/delete_order.dart';
import 'package:pharma_orders/features/orders/domain/usecases/save_order.dart';
import 'package:pharma_orders/features/orders/domain/usecases/watch_orders.dart';

/// حاوية حقن الاعتماديات اليدوية: كل حالات الاستخدام الجاهزة للشاشات.
/// بتتبني مرة واحدة في injection.dart وبتتمرر للتطبيق كله.
class Backend {
  // auth
  final RestoreSession restoreSession;
  final SignIn signIn;
  final SignUp signUp;
  final SignInWithGoogle signInWithGoogle;
  final SendPasswordReset sendPasswordReset;
  final SignOut signOut;
  // catalog
  final WatchDoctors watchDoctors;
  final SaveDoctor saveDoctor;
  final DeleteDoctor deleteDoctor;
  final WatchMedicines watchMedicines;
  final SaveMedicine saveMedicine;
  final DeleteMedicine deleteMedicine;
  final SeedCatalogIfEmpty seedCatalogIfEmpty;
  // orders
  final WatchOrders watchOrders;
  final SaveOrder saveOrder;
  final DeleteOrder deleteOrder;

  /// true مع Firebase: بنعرض حالة المزامنة (مستنية النت / اتزامنت).
  final bool tracksSync;

  /// true في الوضع التجريبي (من غير Firebase).
  final bool isDemo;

  const Backend({
    required this.restoreSession,
    required this.signIn,
    required this.signUp,
    required this.signInWithGoogle,
    required this.sendPasswordReset,
    required this.signOut,
    required this.watchDoctors,
    required this.saveDoctor,
    required this.deleteDoctor,
    required this.watchMedicines,
    required this.saveMedicine,
    required this.deleteMedicine,
    required this.seedCatalogIfEmpty,
    required this.watchOrders,
    required this.saveOrder,
    required this.deleteOrder,
    required this.tracksSync,
    required this.isDemo,
  });
}
