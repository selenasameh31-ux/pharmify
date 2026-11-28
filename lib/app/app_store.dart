import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:pharma_orders/core/di/backend.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:pharma_orders/features/auth/domain/entities/app_user.dart';
import 'package:pharma_orders/features/doctors/domain/entities/doctor.dart';
import 'package:pharma_orders/features/medicines/domain/entities/medicine.dart';
import 'package:pharma_orders/features/orders/domain/entities/order.dart';

/// حالة التطبيق للمستخدم الحالي. الشاشات بتسمع له وبتتحدث تلقائي
/// (ومع Firebase بتتحدث لحظيًا لما أي مندوب يسجل طلبية).
/// بيستخدم حالات الاستخدام (use cases) من طبقة الدومين، مش مصادر البيانات مباشرة.
class AppStore extends ChangeNotifier {
  AppStore(this._backend, this.user);

  final Backend _backend;
  final AppUser user;

  List<Doctor> doctors = [];
  List<Medicine> medicines = [];
  List<Order> orders = []; // الأحدث الأول
  String? error;

  final List<StreamSubscription<dynamic>> _subs = [];

  Future<void> start() async {
    try {
      await _backend.seedCatalogIfEmpty();
    } catch (e) {
      // ممكن يفشل لو مفيش نت أول مرة، مش مشكلة: هيتعمل بعدين.
      debugPrint('seed skipped: $e');
    }
    _subs.add(_backend.watchDoctors().listen((v) {
      doctors = v;
      notifyListeners();
    }, onError: _fail));
    _subs.add(_backend.watchMedicines().listen((v) {
      medicines = v;
      notifyListeners();
    }, onError: _fail));
    _subs.add(_backend.watchOrders(user).listen((v) {
      orders = [...v]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }, onError: _fail));
  }

  void _fail(Object e) {
    error = tr('مشكلة في الاتصال بقاعدة البيانات. اتأكد من الإنترنت وقواعد Firestore.', 'Database connection problem. Check your internet and Firestore rules.');
    debugPrint('store error: $e');
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // الكتابة بتتعمل من غير انتظار عشان التطبيق يفضل سريع حتى لو النت بطيء.
  void _run(Future<void> f) => f.catchError(_fail);

  void saveOrder(Order o) => _run(_backend.saveOrder(o));
  void deleteOrder(String id) => _run(_backend.deleteOrder(id));
  void saveDoctor(Doctor d) => _run(_backend.saveDoctor(d));
  void deleteDoctor(String id) => _run(_backend.deleteDoctor(id));
  void saveMedicine(Medicine m) => _run(_backend.saveMedicine(m));
  void deleteMedicine(String id) => _run(_backend.deleteMedicine(id));

  bool get showSync => _backend.tracksSync;

  int get pendingCount => orders.where((o) => o.pending).length;

  /// آخر 7 أيام (للمندوب).
  List<Order> get weekOrders {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return orders.where((o) => !o.createdAt.isBefore(start)).toList();
  }
}
