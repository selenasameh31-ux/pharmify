import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:flutter/services.dart';

import 'package:pharma_orders/app/app_store.dart';
import 'package:pharma_orders/features/orders/domain/entities/order.dart';
import 'package:pharma_orders/core/widgets/common.dart';
import 'package:pharma_orders/core/widgets/contact_buttons.dart';
import 'package:pharma_orders/core/utils/invoice_share.dart';
import 'package:pharma_orders/core/widgets/medicine_thumb.dart';
import 'package:pharma_orders/core/widgets/select_sheet.dart';

/// شاشة إضافة / تعديل طلبية. مفيش كتابة أسماء: اختيار دكتور واختيار أدوية
/// من القوائم، وبعدين الكميات بس.
class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key, required this.store, this.existing});

  final AppStore store;
  final Order? existing;

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  String? _doctorId;
  String _doctorName = '';
  final List<OrderItem> _items = [];
  late final TextEditingController _notes;
  late final DateTime _createdAt;
  bool _showErrors = false;

  bool get _editing => widget.existing != null;

  String get _doctorPhone {
    for (final d in widget.store.doctors) {
      if (d.id == _doctorId) return d.phone;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _notes = TextEditingController(text: e?.notes ?? '');
    _createdAt = e?.createdAt ?? DateTime.now(); // التاريخ والوقت تلقائي
    if (e != null) {
      _doctorId = e.doctorId;
      _doctorName = e.doctorName;
      _items.addAll(e.items);
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDoctor() async {
    final doctors = widget.store.doctors;
    final res = await showSelectSheet(
      context,
      title: tr('اختار الدكتور', 'Choose the doctor'),
      multi: false,
      initial: {?_doctorId},
      options: [for (final d in doctors) SelectOption(d.id, d.name, d.specialty)],
      emptyText: tr('ضيف أطباء من شاشة القوائم الأول', 'Add doctors from the Lists screen first'),
    );
    if (res == null || res.isEmpty) return;
    final found = doctors.where((x) => x.id == res.first);
    if (found.isEmpty) return;
    final d = found.first;
    setState(() {
      _doctorId = d.id;
      _doctorName = d.name;
    });
  }

  Future<void> _pickMedicines() async {
    final meds = widget.store.medicines;
    final res = await showSelectSheet(
      context,
      title: tr('اختار الأدوية', 'Choose medicines'),
      multi: true,
      initial: _items
          .map((e) => e.medicineId)
          .where((id) => meds.any((m) => m.id == id))
          .toSet(),
      options: [for (final m in meds) SelectOption(m.id, m.name, m.form, MedicineThumb(m, size: 40))],
      emptyText: tr('ضيف أدوية من شاشة القوائم الأول', 'Add medicines from the Lists screen first'),
    );
    if (res == null) return;
    setState(() {
      // نحافظ على الكميات القديمة للأدوية اللي لسه مختارة
      _items.removeWhere((it) =>
          !res.contains(it.medicineId) &&
          meds.any((m) => m.id == it.medicineId));
      for (final id in res) {
        if (_items.any((it) => it.medicineId == id)) continue;
        final found = meds.where((x) => x.id == id);
        if (found.isEmpty) continue; // الدوا اتمسح من القائمة بعد الطلبية
        final m = found.first;
        _items.add(OrderItem(
            medicineId: m.id,
            medicineName: m.name,
            quantity: 1,
            unitPrice: m.price));
      }
    });
  }

  Future<void> _editQuantity(int index) async {
    final ctrl = TextEditingController(text: '${_items[index].quantity}');
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_items[index].medicineName),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(labelText: tr('الكمية', 'Quantity')),
          onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(tr('إلغاء', 'Cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
            child: Text(tr('تم', 'Done')),
          ),
        ],
      ),
    );
    if (value != null && value > 0) {
      setState(() => _items[index] =
          _items[index].copyWith(quantity: value > 100000 ? 100000 : value));
    }
  }

  void _save() {
    if (_doctorId == null || _items.isEmpty) {
      setState(() => _showErrors = true);
      return;
    }
    final store = widget.store;
    final order = Order(
      id: widget.existing?.id ?? store.newId(),
      repId: widget.existing?.repId ?? store.user.uid,
      repName: widget.existing?.repName ?? store.user.name,
      doctorId: _doctorId!,
      doctorName: _doctorName,
      items: List.of(_items),
      notes: _notes.text.trim(),
      createdAt: _createdAt,
    );
    final messenger = ScaffoldMessenger.of(context);
    store.saveOrder(order);
    Navigator.pop(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_editing ? tr('تم تعديل الطلبية', 'Order updated') : tr('تم حفظ الطلبية ✅', 'Order saved ✅'))));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = _items.fold<int>(0, (s, i) => s + i.quantity);
    final value = _items.fold<double>(0, (s, i) => s + i.total);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? tr('تعديل الطلبية', 'Edit order') : tr('طلبية جديدة', 'New order'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_editing)
            IconButton(
              tooltip: tr('فاتورة PDF', 'PDF invoice'),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () => shareInvoice(context, widget.existing!),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // التاريخ والوقت
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(formatFull(_createdAt),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(tr('الدكتور', 'Doctor')),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _pickDoctor,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _doctorId == null
                        ? CircleAvatar(
                            radius: 23,
                            backgroundColor: scheme.surfaceContainerHighest,
                            child: const Icon(Icons.person_search_rounded))
                        : InitialAvatar(_doctorName),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _doctorId == null ? tr('اختار الدكتور', 'Choose the doctor') : _doctorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _doctorId == null
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
              ),
            ),
          ),
          if (_doctorId != null && _doctorPhone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ContactButtons(phone: _doctorPhone),
            ),
          if (_showErrors && _doctorId == null)
            _ErrorText(tr('لازم تختار دكتور', 'Please choose a doctor')),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _SectionTitle(tr('الأدوية', 'Medicines'))),
              TextButton.icon(
                onPressed: _pickMedicines,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: Text(_items.isEmpty ? tr('اختار أدوية', 'Choose medicines') : tr('تعديل الاختيار', 'Edit selection')),
              ),
            ],
          ),
          if (_items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Center(
                  child: Text(tr('لسه ما اخترتش أدوية', 'No medicines chosen yet'),
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _ItemRow(
                      item: _items[i],
                      onMinus: () => setState(() {
                        final q = _items[i].quantity;
                        if (q > 1) _items[i] = _items[i].copyWith(quantity: q - 1);
                      }),
                      onPlus: () => setState(() => _items[i] =
                          _items[i].copyWith(quantity: _items[i].quantity + 1)),
                      onTapQty: () => _editQuantity(i),
                      onRemove: () => setState(() => _items.removeAt(i)),
                    ),
                  ],
                ],
              ),
            ),
          if (_showErrors && _items.isEmpty) _ErrorText(tr('اختار دوا واحد على الأقل', 'Choose at least one medicine')),
          const SizedBox(height: 20),
          _SectionTitle(tr('ملاحظات (اختياري)', 'Notes (optional)')),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(hintText: tr('أي ملاحظة عن الزيارة', 'Any note about the visit')),
          ),
          const SizedBox(height: 24),
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                  value > 0
                      ? tr('إجمالي العبوات: $total  •  ${formatMoney(value)}', 'Total packs: $total  •  ${formatMoney(value)}')
                      : tr('إجمالي العبوات: $total', 'Total packs: $total'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: scheme.primary)),
            ),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(_editing ? tr('حفظ التعديل', 'Save changes') : tr('حفظ الطلبية', 'Save order')),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, right: 6),
        child: Text(text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error, fontSize: 13)),
      );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onTapQty,
    required this.onRemove,
  });

  final OrderItem item;
  final VoidCallback onMinus, onPlus, onTapQty, onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(item.medicineName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          Container(
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onPlus,
                  icon: const Icon(Icons.add_rounded),
                  visualDensity: VisualDensity.compact,
                ),
                InkWell(
                  onTap: onTapQty,
                  child: SizedBox(
                    width: 38,
                    child: Text('${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(
                  onPressed: item.quantity > 1 ? onMinus : null,
                  icon: const Icon(Icons.remove_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
