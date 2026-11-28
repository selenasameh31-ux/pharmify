import '../../domain/entities/medicine.dart';

/// نموذج طبقة البيانات لـ Medicine: يضيف التحويل من/إلى JSON وFirestore.
class MedicineModel extends Medicine {
  const MedicineModel({
    required super.id,
    required super.name,
    super.form,
    super.price,
  });

  factory MedicineModel.fromEntity(Medicine m) => MedicineModel(
      id: m.id, name: m.name, form: m.form, price: m.price);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'form': form,
        'price': price,
      };

  /// نفس شكل التخزين في Firestore (medicines/{id}).
  Map<String, dynamic> toFirestore() => toJson();

  factory MedicineModel.fromJson(Map<String, dynamic> j) => MedicineModel(
        id: j['id'] as String,
        name: j['name'] as String,
        form: (j['form'] ?? '') as String,
        price: ((j['price'] ?? 0) as num).toDouble(),
      );

  factory MedicineModel.fromFirestore(Map<String, dynamic> data, String id) =>
      MedicineModel.fromJson({...data, 'id': id});
}
