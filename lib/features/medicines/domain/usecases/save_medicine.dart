import '../entities/medicine.dart';
import '../repositories/medicines_repository.dart';

/// حالة استخدام: إضافة أو تعديل دواء.
class SaveMedicine {
  final MedicinesRepository _repo;
  const SaveMedicine(this._repo);
  Future<void> call(Medicine m) => _repo.saveMedicine(m);
}
