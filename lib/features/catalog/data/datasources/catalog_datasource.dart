import '../../../doctors/domain/entities/doctor.dart';
import '../../../medicines/domain/entities/medicine.dart';

/// عقد مصدر بيانات القوائم (أطباء + أدوية + التهيئة الأولى).
/// فيه تنفيذين: Firestore على السيرفر ومحلي على الجهاز (الوضع التجريبي).
abstract class CatalogDataSource {
  Future<void> seedIfEmpty();

  Stream<List<Doctor>> watchDoctors();
  Future<void> saveDoctor(Doctor d);
  Future<void> deleteDoctor(String id);

  Stream<List<Medicine>> watchMedicines();
  Future<void> saveMedicine(Medicine m);
  Future<void> deleteMedicine(String id);
}
