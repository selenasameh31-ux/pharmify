import '../../domain/entities/order.dart';

/// نموذج طبقة البيانات لـ OrderItem.
class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.medicineId,
    required super.medicineName,
    required super.quantity,
    super.unitPrice,
  });

  factory OrderItemModel.fromEntity(OrderItem i) => OrderItemModel(
        medicineId: i.medicineId,
        medicineName: i.medicineName,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
      );

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        medicineId: j['medicineId'] as String,
        medicineName: j['medicineName'] as String,
        quantity: (j['quantity'] as num).toInt(),
        unitPrice: ((j['unitPrice'] ?? 0) as num).toDouble(),
      );
}

/// نموذج طبقة البيانات لـ Order: يضيف التحويل من/إلى JSON وFirestore.
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.repId,
    required super.repName,
    required super.doctorId,
    required super.doctorName,
    required super.items,
    required super.createdAt,
    super.notes,
    super.pending,
  });

  factory OrderModel.fromEntity(Order o) => OrderModel(
        id: o.id,
        repId: o.repId,
        repName: o.repName,
        doctorId: o.doctorId,
        doctorName: o.doctorName,
        items: o.items,
        createdAt: o.createdAt,
        notes: o.notes,
        pending: o.pending,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'repId': repId,
        'repName': repName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'items': items
            .map((e) => OrderItemModel.fromEntity(e).toJson())
            .toList(),
        'notes': notes,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  /// نفس شكل التخزين في Firestore (orders/{id}).
  Map<String, dynamic> toFirestore() => toJson();

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'] as String,
        repId: (j['repId'] ?? '') as String,
        repName: (j['repName'] ?? '') as String,
        doctorId: (j['doctorId'] ?? '') as String,
        doctorName: j['doctorName'] as String,
        items: List<OrderItem>.from((j['items'] as List).map((e) =>
            OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))),
        notes: (j['notes'] ?? '') as String,
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      );

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) =>
      OrderModel.fromJson({...data, 'id': id});
}
