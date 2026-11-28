import '../repositories/medicines_repository.dart';

/// حالة استخدام: مسح دواء.
class DeleteMedicine {
  final MedicinesRepository _repo;
  const DeleteMedicine(this._repo);
  Future<void> call(String id) => _repo.deleteMedicine(id);
}
