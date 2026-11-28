import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';
import 'orders_datasource.dart';

/// مصدر بيانات الطلبيات في الوضع التجريبي: كل حاجة على الجهاز نفسه.
class LocalOrdersDataSource implements OrdersDataSource {
  LocalOrdersDataSource(this._prefs) {
    _orders = _read('orders_v2', OrderModel.fromJson, <Order>[]);
  }

  final SharedPreferences _prefs;

  @override
  bool get tracksSync => false;

  late List<Order> _orders;

  final _ordersCtl = StreamController<void>.broadcast();

  List<T> _read<T>(String key, T Function(Map<String, dynamic>) fromJson,
      List<T> fallback) {
    final raw = _prefs.getString(key);
    if (raw == null) return fallback;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _write(String key, List<Map<String, dynamic>> data) =>
      _prefs.setString(key, jsonEncode(data));

  Stream<T> _withInitial<T>(T Function() current, Stream<dynamic> changes) async* {
    yield current();
    await for (final _ in changes) {
      yield current();
    }
  }

  @override
  Stream<List<Order>> watchOrders(AppUser user) => _withInitial(
        () => _orders.where((o) => user.isAdmin || o.repId == user.uid).toList(),
        _ordersCtl.stream,
      );

  void _upsert<T>(List<T> list, T item, String Function(T) id) {
    final i = list.indexWhere((x) => id(x) == id(item));
    if (i >= 0) {
      list[i] = item;
    } else {
      list.add(item);
    }
  }

  @override
  Future<void> saveOrder(Order o) async {
    _upsert(_orders, o, (x) => x.id);
    _ordersCtl.add(null);
    await _write('orders_v2',
        _orders.map((e) => OrderModel.fromEntity(e).toJson()).toList());
  }

  @override
  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    _ordersCtl.add(null);
    await _write('orders_v2',
        _orders.map((e) => OrderModel.fromEntity(e).toJson()).toList());
  }
}
