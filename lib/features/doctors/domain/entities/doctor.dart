/// طبيب بيزوره المندوب. كيان نقي في طبقة الدومين.
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String phone; // رقم التليفون (اختياري)

  const Doctor({
    required this.id,
    required this.name,
    this.specialty = '',
    this.phone = '',
  });

  Doctor copyWith({String? name, String? specialty, String? phone}) => Doctor(
        id: id,
        name: name ?? this.name,
        specialty: specialty ?? this.specialty,
        phone: phone ?? this.phone,
      );
}
