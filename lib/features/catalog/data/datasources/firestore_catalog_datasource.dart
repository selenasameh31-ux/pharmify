import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../doctors/data/datasources/seed_doctors.dart';
import '../../../doctors/data/models/doctor_model.dart';
import '../../../doctors/domain/entities/doctor.dart';
import '../../../medicines/data/datasources/seed_medicines.dart';
import '../../../medicines/data/models/medicine_model.dart';
import '../../../medicines/domain/entities/medicine.dart';
import 'catalog_datasource.dart';

/// مستند تالف (حقل ناقص مثلًا) بيتجاهل بدل ما يوقّع القايمة كلها.
T? _safe<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}

/// مصدر بيانات القوائم على Cloud Firestore.
class FirestoreCatalogDataSource implements CatalogDataSource {
  FirestoreCatalogDataSource(this._prefs);
  final SharedPreferences _prefs;

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _doctors =>
      _db.collection('doctors');
  CollectionReference<Map<String, dynamic>> get _medicines =>
      _db.collection('medicines');

  @override
  Future<void> seedIfEmpty() async {
    // البيانات التجريبية بتتحط مرة واحدة بس على الجهاز، عشان لو اتمسحت
    // القوايم ما ترجعش لوحدها.
    if (_prefs.getBool('seeded_v1') == true) return;
    final batch = _db.batch();
    var any = false;
    if ((await _doctors.limit(1).get()).docs.isEmpty) {
      for (final d in seedDoctors) {
        batch.set(_doctors.doc(d.id), DoctorModel.fromEntity(d).toFirestore());
      }
      any = true;
    }
    if ((await _medicines.limit(1).get()).docs.isEmpty) {
      for (final m in seedMedicines) {
        batch.set(
            _medicines.doc(m.id), MedicineModel.fromEntity(m).toFirestore());
      }
      any = true;
    }
    if (any) await batch.commit();
    await _prefs.setBool('seeded_v1', true);
    await _backfillSeedPhones();
  }

  /// ترقية مرة واحدة: بتحط أرقام التليفونات الوهمية للدكاترة التجريبيين
  /// اللي اتسجلوا قبل ما الأرقام تتضاف للسيد. بتملى الرقم بس لو فاضي،
  /// ومبترجعش دكتور المستخدم مسحه، ومبتلمسش رقم المستخدم عدّله.
  Future<void> _backfillSeedPhones() async {
    if (_prefs.getBool('seed_phones_v1') == true) return;
    for (final seed in seedDoctors) {
      final snap = await _doctors.doc(seed.id).get();
      if (!snap.exists) continue;
      final current = _safe(() => DoctorModel.fromFirestore(snap.data()!, snap.id));
      if (current != null && current.phone.isEmpty && seed.phone.isNotEmpty) {
        await _doctors.doc(seed.id).update({'phone': seed.phone});
      }
    }
    await _prefs.setBool('seed_phones_v1', true);
  }

  @override
  Stream<List<Doctor>> watchDoctors() => _doctors.snapshots().map((s) => s.docs
      .map((d) => _safe(() => DoctorModel.fromFirestore(d.data(), d.id)))
      .nonNulls
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name)));

  @override
  Stream<List<Medicine>> watchMedicines() => _medicines.snapshots().map((s) =>
      s.docs
          .map((d) => _safe(() => MedicineModel.fromFirestore(d.data(), d.id)))
          .nonNulls
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)));

  @override
  Future<void> saveDoctor(Doctor d) =>
      _doctors.doc(d.id).set(DoctorModel.fromEntity(d).toFirestore());

  @override
  Future<void> deleteDoctor(String id) => _doctors.doc(id).delete();

  @override
  Future<void> saveMedicine(Medicine m) =>
      _medicines.doc(m.id).set(MedicineModel.fromEntity(m).toFirestore());

  @override
  Future<void> deleteMedicine(String id) => _medicines.doc(id).delete();
}
