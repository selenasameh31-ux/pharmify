import '../repositories/doctors_repository.dart';

/// حالة استخدام: مسح طبيب.
class DeleteDoctor {
  final DoctorsRepository _repo;
  const DeleteDoctor(this._repo);
  Future<void> call(String id) => _repo.deleteDoctor(id);
}
