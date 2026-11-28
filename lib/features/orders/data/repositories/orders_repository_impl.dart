import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_datasource.dart';

/// تنفيذ عقد الطلبيات: بيمرر النداءات لمصدر البيانات المختار.
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource _ds;
  const OrdersRepositoryImpl(this._ds);

  @override
  bool get tracksSync => _ds.tracksSync;
  @override
  Stream<List<Order>> watchOrders(AppUser user) => _ds.watchOrders(user);
  @override
  Future<void> saveOrder(Order o) => _ds.saveOrder(o);
  @override
  Future<void> deleteOrder(String id) => _ds.deleteOrder(id);
}
