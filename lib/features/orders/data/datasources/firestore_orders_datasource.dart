import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';
import 'orders_datasource.dart';

/// مستند تالف (حقل ناقص مثلًا) بيتجاهل بدل ما يوقّع القايمة كلها.
T? _safe<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}

/// مصدر بيانات الطلبيات على Cloud Firestore.
class FirestoreOrdersDataSource implements OrdersDataSource {
  @override
  bool get tracksSync => true;

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  @override
  Stream<List<Order>> watchOrders(AppUser user) {
    final Query<Map<String, dynamic>> q =
        user.isAdmin ? _orders : _orders.where('repId', isEqualTo: user.uid);
    // includeMetadataChanges: عشان نعرف أمتى الطلبية اترفعت فعلًا للسيرفر
    return q.snapshots(includeMetadataChanges: true).map((s) => s.docs
        .map((d) => _safe(() => OrderModel.fromFirestore(d.data(), d.id)
            .markPending(d.metadata.hasPendingWrites)))
        .nonNulls
        .toList());
  }

  @override
  Future<void> saveOrder(Order o) =>
      _orders.doc(o.id).set(OrderModel.fromEntity(o).toFirestore());

  @override
  Future<void> deleteOrder(String id) => _orders.doc(id).delete();
}
