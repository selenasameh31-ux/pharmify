import '../entities/doctor.dart';
import '../repositories/doctors_repository.dart';

/// حالة استخدام: إضافة أو تعديل طبيب.
class SaveDoctor {
  final DoctorsRepository _repo;
  const SaveDoctor(this._repo);
  Future<void> call(Doctor d) => _repo.saveDoctor(d);
}
