/// دواء في قايمة الشركة. كيان نقي في طبقة الدومين.
class Medicine {
  final String id;
  final String name;
  final String form; // شراب، أقراص، ...
  final double price; // سعر العبوة بالجنيه

  const Medicine({
    required this.id,
    required this.name,
    this.form = '',
    this.price = 0,
  });

  Medicine copyWith({String? name, String? form, double? price}) => Medicine(
        id: id,
        name: name ?? this.name,
        form: form ?? this.form,
        price: price ?? this.price,
      );
}
