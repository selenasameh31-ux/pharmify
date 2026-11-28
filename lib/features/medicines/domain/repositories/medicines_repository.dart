import '../entities/medicine.dart';

/// عقد طبقة الدومين لبيانات الأدوية.
abstract class MedicinesRepository {
  Stream<List<Medicine>> watchMedicines();
  Future<void> saveMedicine(Medicine m);
  Future<void> deleteMedicine(String id);
}
