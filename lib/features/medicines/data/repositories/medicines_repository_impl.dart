import '../../../catalog/data/datasources/catalog_datasource.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicines_repository.dart';

/// تنفيذ عقد الأدوية: بيمرر النداءات لمصدر بيانات القوائم.
class MedicinesRepositoryImpl implements MedicinesRepository {
  final CatalogDataSource _ds;
  const MedicinesRepositoryImpl(this._ds);

  @override
  Stream<List<Medicine>> watchMedicines() => _ds.watchMedicines();
  @override
  Future<void> saveMedicine(Medicine m) => _ds.saveMedicine(m);
  @override
  Future<void> deleteMedicine(String id) => _ds.deleteMedicine(id);
}
