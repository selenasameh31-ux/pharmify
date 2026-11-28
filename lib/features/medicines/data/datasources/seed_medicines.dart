import '../../domain/entities/medicine.dart';

/// أدوية تجريبية بأسعار مصرية عشان التطبيق يشتغل فورًا.
/// الأسماء والأسعار دي أمثلة للتجربة بس، وتتعدل أو تتمسح من شاشة "القوائم".
const List<Medicine> seedMedicines = [
  Medicine(id: 'm1', name: 'بانادول إكسترا', form: 'أقراص', price: 62),
  Medicine(id: 'm2', name: 'أوجمنتين 1 جم', form: 'أقراص', price: 165),
  Medicine(id: 'm3', name: 'كونكور 5 مجم', form: 'أقراص', price: 140),
  Medicine(id: 'm4', name: 'جلوكوفاج 500 مجم', form: 'أقراص', price: 48),
  Medicine(id: 'm5', name: 'نيكسيوم 40 مجم', form: 'أقراص', price: 185),
  Medicine(id: 'm6', name: 'فلاجيل', form: 'أقراص', price: 30),
  Medicine(id: 'm7', name: 'كتافاست 50 مجم', form: 'أقراص', price: 120),
  Medicine(id: 'm8', name: 'فولتارين 75 مجم', form: 'حقن', price: 55),
  Medicine(id: 'm9', name: 'أنتينال', form: 'أقراص', price: 20),
  Medicine(id: 'm10', name: 'سيتال', form: 'شراب', price: 38),
  Medicine(id: 'm11', name: 'بروفين 400 مجم', form: 'أقراص', price: 35),
  Medicine(id: 'm12', name: 'زيرتك', form: 'أقراص', price: 70),
  Medicine(id: 'm13', name: 'فنتولين', form: 'بخاخ', price: 45),
  Medicine(id: 'm14', name: 'سبراي لوراتادين', form: 'شراب', price: 32),
  Medicine(id: 'm15', name: 'كلاريتين', form: 'شراب', price: 40),
  Medicine(id: 'm16', name: 'نوفالجين', form: 'أقراص', price: 42),
];
