import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/order.dart';

/// عقد مصدر بيانات الطلبيات: Firestore على السيرفر أو محلي على الجهاز.
abstract class OrdersDataSource {
  /// true مع Firebase: بنعرض حالة المزامنة (مستنية النت / اتزامنت).
  bool get tracksSync;

  /// المندوب بيشوف طلبياته بس، والأدمن بيشوف كل الطلبيات.
  Stream<List<Order>> watchOrders(AppUser user);
  Future<void> saveOrder(Order o);
  Future<void> deleteOrder(String id);
}
