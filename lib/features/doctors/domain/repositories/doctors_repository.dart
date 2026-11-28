import '../entities/doctor.dart';

/// عقد طبقة الدومين لبيانات الأطباء.
abstract class DoctorsRepository {
  Stream<List<Doctor>> watchDoctors();
  Future<void> saveDoctor(Doctor d);
  Future<void> deleteDoctor(String id);
}
