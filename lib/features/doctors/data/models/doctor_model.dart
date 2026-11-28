import '../../domain/entities/doctor.dart';

/// نموذج طبقة البيانات لـ Doctor: يضيف التحويل من/إلى JSON وFirestore.
class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.name,
    super.specialty,
    super.phone,
  });

  factory DoctorModel.fromEntity(Doctor d) => DoctorModel(
      id: d.id, name: d.name, specialty: d.specialty, phone: d.phone);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'specialty': specialty, 'phone': phone};

  /// نفس شكل التخزين في Firestore (doctors/{id}).
  Map<String, dynamic> toFirestore() => toJson();

  factory DoctorModel.fromJson(Map<String, dynamic> j) => DoctorModel(
        id: j['id'] as String,
        name: j['name'] as String,
        specialty: (j['specialty'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
      );

  factory DoctorModel.fromFirestore(Map<String, dynamic> data, String id) =>
      DoctorModel.fromJson({...data, 'id': id});
}
