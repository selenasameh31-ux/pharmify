import 'package:material_ui/material_ui.dart';

import 'package:pharma_orders/features/medicines/domain/entities/medicine.dart';

/// أيقونة الدوا (دايرة صغيرة).
class MedicineThumb extends StatelessWidget {
  const MedicineThumb(this.medicine, {super.key, this.size = 44});

  final Medicine medicine;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: scheme.tertiaryContainer,
        child: Icon(Icons.medication_rounded,
            size: size * .55, color: scheme.onTertiaryContainer),
      ),
    );
  }
}
