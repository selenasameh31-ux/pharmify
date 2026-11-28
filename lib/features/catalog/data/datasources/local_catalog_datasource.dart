import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../doctors/data/datasources/seed_doctors.dart';
import '../../../doctors/data/models/doctor_model.dart';
import '../../../doctors/domain/entities/doctor.dart';
import '../../../medicines/data/datasources/seed_medicines.dart';
import '../../../medicines/data/models/medicine_model.dart';
import '../../../medicines/domain/entities/medicine.dart';
import 'catalog_datasource.dart';

/// مصدر بيانات القوائم في الوضع التجريبي: كل حاجة على الجهاز نفسه
/// من غير إنترنت ولا Firebase.
class LocalCatalogDataSource implements CatalogDataSource {
  LocalCatalogDataSource(this._prefs) {
    _doctors =
        _read('doctors_v2', DoctorModel.fromJson, List.of(seedDoctors));
    _medicines =
        _read('medicines_v2', MedicineModel.fromJson, List.of(seedMedicines));
    _backfillSeedPhones();
  }

  /// ترقية مرة واحدة: بتحط أرقام التليفونات الوهمية للدكاترة التجريبيين
  /// المخزنين على الجهاز من قبل ما الأرقام تتضاف للسيد. بتملى الرقم بس لو
  /// فاضي، ومبترجعش دكتور المستخدم مسحه.
  void _backfillSeedPhones() {
    var changed = false;
    for (final seed in seedDoctors) {
      final i = _doctors.indexWhere((d) => d.id == seed.id);
      if (i >= 0 && _doctors[i].phone.isEmpty && seed.phone.isNotEmpty) {
        _doctors[i] = _doctors[i].copyWith(phone: seed.phone);
        changed = true;
      }
    }
    if (changed) {
      _write('doctors_v2',
          _doctors.map((e) => DoctorModel.fromEntity(e).toJson()).toList());
    }
  }

  final SharedPreferences _prefs;

  late List<Doctor> _doctors;
  late List<Medicine> _medicines;

  final _doctorsCtl = StreamController<List<Doctor>>.broadcast();
  final _medicinesCtl = StreamController<List<Medicine>>.broadcast();

  List<T> _read<T>(String key, T Function(Map<String, dynamic>) fromJson,
      List<T> fallback) {
    final raw = _prefs.getString(key);
    if (raw == null) return fallback;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _write(String key, List<Map<String, dynamic>> data) =>
      _prefs.setString(key, jsonEncode(data));

  Stream<T> _withInitial<T>(T Function() current, Stream<dynamic> changes) async* {
    yield current();
    await for (final _ in changes) {
      yield current();
    }
  }

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Stream<List<Doctor>> watchDoctors() =>
      _withInitial(() => List.of(_doctors), _doctorsCtl.stream);

  @override
  Stream<List<Medicine>> watchMedicines() =>
      _withInitial(() => List.of(_medicines), _medicinesCtl.stream);

  void _upsert<T>(List<T> list, T item, String Function(T) id) {
    final i = list.indexWhere((x) => id(x) == id(item));
    if (i >= 0) {
      list[i] = item;
    } else {
      list.add(item);
    }
  }

  @override
  Future<void> saveDoctor(Doctor d) async {
    _upsert(_doctors, d, (x) => x.id);
    _doctorsCtl.add(_doctors);
    await _write('doctors_v2',
        _doctors.map((e) => DoctorModel.fromEntity(e).toJson()).toList());
  }

  @override
  Future<void> deleteDoctor(String id) async {
    _doctors.removeWhere((d) => d.id == id);
    _doctorsCtl.add(_doctors);
    await _write('doctors_v2',
        _doctors.map((e) => DoctorModel.fromEntity(e).toJson()).toList());
  }

  @override
  Future<void> saveMedicine(Medicine m) async {
    _upsert(_medicines, m, (x) => x.id);
    _medicinesCtl.add(_medicines);
    await _write('medicines_v2',
        _medicines.map((e) => MedicineModel.fromEntity(e).toJson()).toList());
  }

  @override
  Future<void> deleteMedicine(String id) async {
    _medicines.removeWhere((m) => m.id == id);
    _medicinesCtl.add(_medicines);
    await _write('medicines_v2',
        _medicines.map((e) => MedicineModel.fromEntity(e).toJson()).toList());
  }
}
