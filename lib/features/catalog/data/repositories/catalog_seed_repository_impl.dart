import '../../domain/repositories/catalog_seed_repository.dart';
import '../datasources/catalog_datasource.dart';

/// تنفيذ عقد تهيئة القوائم بالبيانات التجريبية.
class CatalogSeedRepositoryImpl implements CatalogSeedRepository {
  final CatalogDataSource _ds;
  const CatalogSeedRepositoryImpl(this._ds);

  @override
  Future<void> seedIfEmpty() => _ds.seedIfEmpty();
}
