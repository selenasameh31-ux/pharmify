import '../entities/medicine.dart';
import '../repositories/medicines_repository.dart';

/// حالة استخدام: متابعة قايمة الأدوية لحظة بلحظة.
class WatchMedicines {
  final MedicinesRepository _repo;
  const WatchMedicines(this._repo);
  Stream<List<Medicine>> call() => _repo.watchMedicines();
}
