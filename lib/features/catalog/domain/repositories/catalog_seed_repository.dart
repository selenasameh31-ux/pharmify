/// عقد طبقة الدومين لتهيئة القوائم الأساسية (أطباء + أدوية) بالبيانات التجريبية.
abstract class CatalogSeedRepository {
  /// بيضيف الأطباء والأدوية التجريبية لو القوائم فاضية.
  Future<void> seedIfEmpty();
}
