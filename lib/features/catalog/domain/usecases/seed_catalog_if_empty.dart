import '../repositories/catalog_seed_repository.dart';

/// حالة استخدام: تهيئة القوائم بالبيانات التجريبية أول مرة بس.
class SeedCatalogIfEmpty {
  final CatalogSeedRepository _repo;
  const SeedCatalogIfEmpty(this._repo);
  Future<void> call() => _repo.seedIfEmpty();
}
