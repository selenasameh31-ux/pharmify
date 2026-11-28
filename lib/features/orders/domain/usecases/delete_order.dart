import '../repositories/orders_repository.dart';

/// حالة استخدام: مسح طلبية.
class DeleteOrder {
  final OrdersRepository _repo;
  const DeleteOrder(this._repo);
  Future<void> call(String id) => _repo.deleteOrder(id);
}
