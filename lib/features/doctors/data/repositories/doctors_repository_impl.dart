import '../../../catalog/data/datasources/catalog_datasource.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctors_repository.dart';

/// تنفيذ عقد الأطباء: بيمرر النداءات لمصدر بيانات القوائم.
class DoctorsRepositoryImpl implements DoctorsRepository {
  final CatalogDataSource _ds;
  const DoctorsRepositoryImpl(this._ds);

  @override
  Stream<List<Doctor>> watchDoctors() => _ds.watchDoctors();
  @override
  Future<void> saveDoctor(Doctor d) => _ds.saveDoctor(d);
  @override
  Future<void> deleteDoctor(String id) => _ds.deleteDoctor(id);
}
