import '../../../auth/domain/entities/app_user.dart';
import '../entities/order.dart';

/// عقد طبقة الدومين للطلبيات.
abstract class OrdersRepository {
  /// true مع Firebase: بنعرض حالة المزامنة (مستنية النت / اتزامنت).
  bool get tracksSync;

  /// المندوب بيشوف طلبياته بس، والأدمن بيشوف كل الطلبيات.
  Stream<List<Order>> watchOrders(AppUser user);
  Future<void> saveOrder(Order o);
  Future<void> deleteOrder(String id);
}
