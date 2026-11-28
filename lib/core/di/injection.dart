import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pharma_orders/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:pharma_orders/features/auth/data/datasources/local_auth_datasource.dart';
import 'package:pharma_orders/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pharma_orders/features/auth/domain/usecases/restore_session.dart';
import 'package:pharma_orders/features/auth/domain/usecases/send_password_reset.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_in.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_out.dart';
import 'package:pharma_orders/features/auth/domain/usecases/sign_up.dart';
import 'package:pharma_orders/features/catalog/data/datasources/catalog_datasource.dart';
import 'package:pharma_orders/features/catalog/data/datasources/firestore_catalog_datasource.dart';
import 'package:pharma_orders/features/catalog/data/datasources/local_catalog_datasource.dart';
import 'package:pharma_orders/features/catalog/data/repositories/catalog_seed_repository_impl.dart';
import 'package:pharma_orders/features/catalog/domain/usecases/seed_catalog_if_empty.dart';
import 'package:pharma_orders/features/doctors/data/repositories/doctors_repository_impl.dart';
import 'package:pharma_orders/features/doctors/domain/usecases/delete_doctor.dart';
import 'package:pharma_orders/features/doctors/domain/usecases/save_doctor.dart';
import 'package:pharma_orders/features/doctors/domain/usecases/watch_doctors.dart';
import 'package:pharma_orders/features/medicines/data/repositories/medicines_repository_impl.dart';
import 'package:pharma_orders/features/medicines/domain/usecases/delete_medicine.dart';
import 'package:pharma_orders/features/medicines/domain/usecases/save_medicine.dart';
import 'package:pharma_orders/features/medicines/domain/usecases/watch_medicines.dart';
import 'package:pharma_orders/features/orders/data/datasources/firestore_orders_datasource.dart';
import 'package:pharma_orders/features/orders/data/datasources/local_orders_datasource.dart';
import 'package:pharma_orders/features/orders/data/datasources/orders_datasource.dart';
import 'package:pharma_orders/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:pharma_orders/features/orders/domain/usecases/delete_order.dart';
import 'package:pharma_orders/features/orders/domain/usecases/save_order.dart';
import 'package:pharma_orders/features/orders/domain/usecases/watch_orders.dart';
import 'package:pharma_orders/firebase_options.dart';
import 'backend.dart';

/// بيبني كل الاعتماديات (مصادر البيانات ← المستودعات ← حالات الاستخدام)
/// ويرجع Backend جاهز للتطبيق. هنا القرار الوحيد: Firebase ولا وضع تجريبي.
Future<Backend> buildBackend(SharedPreferences prefs) async {
  if (kFirebaseConfigured) {
    // وضع حقيقي: Firebase Auth + Cloud Firestore
    // على الموبايل: الإعدادات بتتقري من google-services.json / GoogleService-Info.plist
    // تلقائي (لو بعثنا إعدادات الويب هنا بتتصادم مع التهيئة الأصلية وترمي خطأ).
    // على الويب: مفيش إعدادات أصلية، فبنبعت إعدادات الويب صراحة.
    await Firebase.initializeApp(options: kIsWeb ? firebaseWebOptions : null);
    // الشغل من غير نت: Firestore بيحفظ الطلبيات على الجهاز ويرفعها لوحده لما النت يرجع.
    // على الموبايل شغال تلقائي، وهنا بنفعله صراحة للويب كمان (Chrome).
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    final authRepo = AuthRepositoryImpl(FirebaseAuthDataSource());
    final CatalogDataSource catalogDs = FirestoreCatalogDataSource(prefs);
    final OrdersDataSource ordersDs = FirestoreOrdersDataSource();
    final doctorsRepo = DoctorsRepositoryImpl(catalogDs);
    final medicinesRepo = MedicinesRepositoryImpl(catalogDs);
    final seedRepo = CatalogSeedRepositoryImpl(catalogDs);
    final ordersRepo = OrdersRepositoryImpl(ordersDs);
    return Backend(
      restoreSession: RestoreSession(authRepo),
      signIn: SignIn(authRepo),
      signUp: SignUp(authRepo),
      signInWithGoogle: SignInWithGoogle(authRepo),
      sendPasswordReset: SendPasswordReset(authRepo),
      signOut: SignOut(authRepo),
      watchDoctors: WatchDoctors(doctorsRepo),
      saveDoctor: SaveDoctor(doctorsRepo),
      deleteDoctor: DeleteDoctor(doctorsRepo),
      watchMedicines: WatchMedicines(medicinesRepo),
      saveMedicine: SaveMedicine(medicinesRepo),
      deleteMedicine: DeleteMedicine(medicinesRepo),
      seedCatalogIfEmpty: SeedCatalogIfEmpty(seedRepo),
      watchOrders: WatchOrders(ordersRepo),
      saveOrder: SaveOrder(ordersRepo),
      deleteOrder: DeleteOrder(ordersRepo),
      tracksSync: ordersRepo.tracksSync,
      isDemo: false,
    );
  }
  // وضع تجريبي على الجهاز لحد ما تتحط إعدادات Firebase
  final authRepo = AuthRepositoryImpl(LocalAuthDataSource(prefs));
  final CatalogDataSource catalogDs = LocalCatalogDataSource(prefs);
  final OrdersDataSource ordersDs = LocalOrdersDataSource(prefs);
  final doctorsRepo = DoctorsRepositoryImpl(catalogDs);
  final medicinesRepo = MedicinesRepositoryImpl(catalogDs);
  final seedRepo = CatalogSeedRepositoryImpl(catalogDs);
  final ordersRepo = OrdersRepositoryImpl(ordersDs);
  return Backend(
    restoreSession: RestoreSession(authRepo),
    signIn: SignIn(authRepo),
    signUp: SignUp(authRepo),
    signInWithGoogle: SignInWithGoogle(authRepo),
    sendPasswordReset: SendPasswordReset(authRepo),
    signOut: SignOut(authRepo),
    watchDoctors: WatchDoctors(doctorsRepo),
    saveDoctor: SaveDoctor(doctorsRepo),
    deleteDoctor: DeleteDoctor(doctorsRepo),
    watchMedicines: WatchMedicines(medicinesRepo),
    saveMedicine: SaveMedicine(medicinesRepo),
    deleteMedicine: DeleteMedicine(medicinesRepo),
    seedCatalogIfEmpty: SeedCatalogIfEmpty(seedRepo),
    watchOrders: WatchOrders(ordersRepo),
    saveOrder: SaveOrder(ordersRepo),
    deleteOrder: DeleteOrder(ordersRepo),
    tracksSync: ordersRepo.tracksSync,
    isDemo: true,
  );
}
