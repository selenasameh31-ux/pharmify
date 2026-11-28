import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// حالة استخدام: تسجيل أو تعديل طلبية.
class SaveOrder {
  final OrdersRepository _repo;
  const SaveOrder(this._repo);
  Future<void> call(Order o) => _repo.saveOrder(o);
}
