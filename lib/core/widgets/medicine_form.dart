import 'package:flutter/services.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:material_ui/material_ui.dart';

import 'package:pharma_orders/app/app_store.dart';
import 'package:pharma_orders/features/medicines/domain/entities/medicine.dart';

/// نافذة إضافة/تعديل دوا. بترجّع الدوا الجاهز للحفظ، أو null لو اتلغت.
Future<Medicine?> showMedicineForm(BuildContext context, AppStore store,
    {Medicine? existing}) {
  return showDialog<Medicine>(
    context: context,
    builder: (_) => _MedicineForm(store: store, existing: existing),
  );
}

class _MedicineForm extends StatefulWidget {
  const _MedicineForm({required this.store, this.existing});
  final AppStore store;
  final Medicine? existing;

  @override
  State<_MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends State<_MedicineForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _form = TextEditingController(text: widget.existing?.form ?? '');
  late final _price = TextEditingController(
      text: (widget.existing?.price ?? 0) == 0
          ? ''
          : '${widget.existing!.price.round()}');
  late final String _id = widget.existing?.id ?? widget.store.newId();

  @override
  void dispose() {
    _name.dispose();
    _form.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      Medicine(
        id: _id,
        name: _name.text.trim(),
        form: _form.text.trim(),
        price: double.tryParse(_price.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? tr('دوا جديد', 'New medicine') : tr('تعديل الدوا', 'Edit medicine')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: tr('اسم الدوا', 'Medicine name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _form,
              decoration:
                  InputDecoration(labelText: tr('الشكل (أقراص، شراب...)', 'Form (tablets, syrup...)')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              decoration: InputDecoration(labelText: tr('سعر العبوة (ج.م)', 'Price per pack (EGP)')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('إلغاء', 'Cancel'))),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
          onPressed: _save,
          child: Text(tr('حفظ', 'Save')),
        ),
      ],
    );
  }
}
