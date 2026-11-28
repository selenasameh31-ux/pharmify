import '../../domain/entities/doctor.dart';

/// أطباء تجريبيون عشان التطبيق يشتغل فورًا.
/// الأسماء والأرقام دي أمثلة وهمية للتجربة بس، وتتعدل أو تتمسح من شاشة "القوائم".
/// (الأرقام 0100000000x مش أرقام حقيقية، مكانها بيتملى برقم الدكتور الحقيقي.)
const List<Doctor> seedDoctors = [
  Doctor(id: 'd1', name: 'د. أحمد منصور', specialty: 'باطنة', phone: '01000000001'),
  Doctor(id: 'd2', name: 'د. منى عبد الرحمن', specialty: 'أطفال', phone: '01000000002'),
  Doctor(id: 'd3', name: 'د. محمود السيد', specialty: 'صدر', phone: '01000000003'),
  Doctor(id: 'd4', name: 'د. هالة فؤاد', specialty: 'نساء وتوليد', phone: '01000000004'),
  Doctor(id: 'd5', name: 'د. كريم عادل', specialty: 'عظام', phone: '01000000005'),
  Doctor(id: 'd6', name: 'د. نهى إبراهيم', specialty: 'جلدية', phone: '01000000006'),
  Doctor(id: 'd7', name: 'د. طارق حسن', specialty: 'قلب', phone: '01000000007'),
  Doctor(id: 'd8', name: 'د. سلمى يوسف', specialty: 'أنف وأذن وحنجرة', phone: '01000000008'),
];
