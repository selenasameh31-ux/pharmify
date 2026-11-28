import '../../../auth/domain/entities/app_user.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// حالة استخدام: متابعة الطلبيات (للمندوب طلبياته، وللأدمن الكل).
class WatchOrders {
  final OrdersRepository _repo;
  const WatchOrders(this._repo);
  Stream<List<Order>> call(AppUser user) => _repo.watchOrders(user);
}
