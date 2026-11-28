import '../../../../features/orders/domain/entities/order.dart';

class MonthStat {
  final DateTime month;
  final int orders;
  final int items;
  final double value;
  const MonthStat(this.month, this.orders, this.items, this.value);
}

/// إحصائيات آخر [count] شهور، الأقدم الأول والشهر الحالي الأخير.
/// منطق دومين نقي: بيحسب على كيانات الطلبيات من غير أي Flutter/Firebase.
List<MonthStat> monthlyStats(List<Order> orders, {int count = 6}) {
  final now = DateTime.now();
  final result = <MonthStat>[];
  for (var i = count - 1; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i);
    final inMonth = orders
        .where((o) => o.createdAt.year == m.year && o.createdAt.month == m.month)
        .toList();
    result.add(MonthStat(
      m,
      inMonth.length,
      inMonth.fold(0, (s, o) => s + o.totalQuantity),
      inMonth.fold(0.0, (s, o) => s + o.totalValue),
    ));
  }
  return result;
}

List<Order> ordersInMonth(List<Order> orders, DateTime month) => orders
    .where((o) => o.createdAt.year == month.year && o.createdAt.month == month.month)
    .toList();

List<MapEntry<String, double>> topBy(
    Iterable<MapEntry<String, double>> entries, int n) {
  final m = <String, double>{};
  for (final e in entries) {
    m[e.key] = (m[e.key] ?? 0) + e.value;
  }
  final l = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return l.take(n).toList();
}
