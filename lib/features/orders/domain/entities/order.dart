/// سطر في الطلبية: دواء + كمية. الاسم والسعر محفوظين جوه الطلبية
/// عشان الطلبيات القديمة تفضل سليمة حتى لو الدواء اتعدل أو اتمسح.
class OrderItem {
  final String medicineId;
  final String medicineName;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    this.unitPrice = 0,
  });

  double get total => quantity * unitPrice;

  OrderItem copyWith({int? quantity}) => OrderItem(
        medicineId: medicineId,
        medicineName: medicineName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
      );
}

/// طلبية مندوب لدكتور. كيان نقي في طبقة الدومين.
class Order {
  final String id;
  final String repId;
  final String repName;
  final String doctorId;
  final String doctorName;
  final List<OrderItem> items;
  final String notes;
  final DateTime createdAt;

  /// true لو الطلبية لسه ما اترفعتش للسيرفر (اتسجلت من غير نت).
  final bool pending;

  const Order({
    required this.id,
    required this.repId,
    required this.repName,
    required this.doctorId,
    required this.doctorName,
    required this.items,
    required this.createdAt,
    this.notes = '',
    this.pending = false,
  });

  Order markPending(bool p) => Order(
        id: id,
        repId: repId,
        repName: repName,
        doctorId: doctorId,
        doctorName: doctorName,
        items: items,
        createdAt: createdAt,
        notes: notes,
        pending: p,
      );

  int get totalQuantity => items.fold(0, (s, i) => s + i.quantity);
  double get totalValue => items.fold(0.0, (s, i) => s + i.total);
}
