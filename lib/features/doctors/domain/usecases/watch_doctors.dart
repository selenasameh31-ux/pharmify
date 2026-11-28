import '../entities/doctor.dart';
import '../repositories/doctors_repository.dart';

/// حالة استخدام: متابعة قايمة الأطباء لحظة بلحظة.
class WatchDoctors {
  final DoctorsRepository _repo;
  const WatchDoctors(this._repo);
  Stream<List<Doctor>> call() => _repo.watchDoctors();
}
