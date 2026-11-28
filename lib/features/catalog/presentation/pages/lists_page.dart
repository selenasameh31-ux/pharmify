import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';

import 'package:pharma_orders/app/app_store.dart';
import 'package:pharma_orders/features/doctors/domain/entities/doctor.dart';
import 'package:pharma_orders/core/widgets/common.dart';
import 'package:pharma_orders/core/widgets/medicine_form.dart';
import 'package:pharma_orders/core/widgets/medicine_thumb.dart';
import 'package:pharma_orders/core/widgets/contact_buttons.dart';
import 'package:pharma_orders/core/widgets/motion.dart';

/// إدارة قائمة الأطباء وقائمة الأدوية. بتتعمل مرة واحدة وبعدين
/// المندوب بيختار منها بس.
class ListsPage extends StatelessWidget {
  const ListsPage({super.key, required this.store, this.trailing});

  final AppStore store;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: kTealGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 18),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20, end: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(tr('القوائم', 'Lists'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ),
                      ?trailing,
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  dividerColor: Colors.transparent,
                  tabs: [Tab(text: tr('الأطباء', 'Doctors')), Tab(text: tr('الأدوية', 'Medicines'))],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DoctorsTab(store: store),
                _MedicinesTab(store: store),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<String>?> _twoFieldDialog(
  BuildContext context, {
  required String title,
  required String label1,
  required String label2,
  String value1 = '',
  String value2 = '',
  String? label3,
  String value3 = '',
  TextInputType keyboard3 =
      const TextInputType.numberWithOptions(decimal: true),
}) {
  final c1 = TextEditingController(text: value1);
  final c2 = TextEditingController(text: value2);
  final c3 = TextEditingController(text: value3);
  String? phoneError;
  return showDialog<List<String>>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: c1,
            autofocus: true,
            decoration: InputDecoration(labelText: label1),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c2,
            decoration: InputDecoration(labelText: label2),
          ),
          if (label3 != null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: c3,
              keyboardType: keyboard3,
              textDirection: TextDirection.ltr,
              decoration:
                  InputDecoration(labelText: label3, errorText: phoneError),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: Text(tr('إلغاء', 'Cancel'))),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
          onPressed: () {
            if (c1.text.trim().isEmpty) return;
            final digits = c3.text.replaceAll(RegExp(r'[^0-9]'), '');
            if (c3.text.trim().isNotEmpty && (digits.length < 8 || digits.length > 15)) {
              setS(() => phoneError = tr('رقم التليفون مش صحيح', 'Invalid phone number'));
              return;
            }
            Navigator.pop(ctx, [c1.text.trim(), c2.text.trim(), c3.text.trim()]);
          },
          child: Text(tr('حفظ', 'Save')),
        ),
      ],
    )),
  );
}


/// مفتاح مقارنة للتليفون: آخر 10 أرقام (بيغطي 010… و+20… و00…)
String _phoneKey(String raw) {
  final d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.length >= 10) return d.substring(d.length - 10);
  return d;
}

/// تطبيع الاسم للمقارنة: شيل التشكيل والتطويل وتوحيد الألف والياء والتاء المربوطة
String _normName(String raw) {
  var s = raw.trim().toLowerCase();
  s = s.replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '');
  s = s.replaceAll(RegExp(r'[\u0623\u0625\u0622]'), '\u0627');
  s = s.replaceAll('\u0649', '\u064A').replaceAll('\u0629', '\u0647');
  s = s.replaceAll(RegExp(r'[^a-z0-9\u0621-\u064A ]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  for (final p in ['دكتور ', 'دكتوره ', 'د. ', 'د ', 'dr. ', 'dr ']) {
    if (s.startsWith(p)) {
      s = s.substring(p.length);
      break;
    }
  }
  return s;
}

/// تشابه أسماء: احتواء في أي اتجاه أو نفس الكلمات بأي ترتيب
bool _nameSimilar(String a, String b) {
  final na = _normName(a);
  final nb = _normName(b);
  if (na.isEmpty || nb.isEmpty) return false;
  if (na == nb || na.contains(nb) || nb.contains(na)) return true;
  final ta = na.split(' ').toSet();
  final tb = nb.split(' ').toSet();
  final shorter = ta.length <= tb.length ? ta : tb;
  final longer = ta.length <= tb.length ? tb : ta;
  return shorter.every(longer.contains);
}

/// دايالوج "الدكتور موجود بالفعل" (لما رقم التليفون يتكرر)
Future<void> _alreadyExistsDialog(BuildContext context, Doctor d) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.person_search_rounded),
      title: Text(tr('الدكتور ده موجود بالفعل', 'This doctor already exists')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: InitialAvatar(d.name, size: 42),
            title: Text(d.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text([d.specialty, d.phone]
                .where((x) => x.isNotEmpty)
                .join(' · ')),
          ),
          const SizedBox(height: 8),
          Text(tr(
              'نفس رقم التليفون مسجل للدكتور ده، ومينفعش يتعمل سجل تاني بنفس الرقم. استخدم الموجود من القايمة.',
              'This phone number is already registered to this doctor, so no second record can be created with it. Use the existing one from the list.')),
        ],
      ),
      actions: [
        FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('تمام', 'Got it'))),
      ],
    ),
  );
}

/// دايالوج الأسماء القريبة قبل إضافة دكتور جديد
Future<bool?> _nearMatchesDialog(BuildContext context, List<Doctor> matches) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.group_rounded),
      title: Text(tr('في أسماء قريبة في القايمة', 'Similar names found')),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(
                'لو الدكتور واحد من دول، استخدمه من القايمة بدل ما يتعمل سجل مكرر.',
                'If the doctor is one of these, use them from the list instead of creating a duplicate.')),
            const SizedBox(height: 8),
            ...matches.map((d) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: InitialAvatar(d.name, size: 38),
                  title: Text(d.name),
                  subtitle: Text([d.specialty, d.phone]
                      .where((x) => x.isNotEmpty)
                      .join(' · ')),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('إلغاء', 'Cancel'))),
        FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('إضافة كدكتور جديد', 'Add as new doctor'))),
      ],
    ),
  );
}


/// خانة بحث مشتركة لقوائم الدكاترة والأدوية (فلترة أثناء الكتابة)
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: tr('دوّر بالاسم', 'Search by name'),
          prefixIcon: const Icon(Icons.search_rounded),
          isDense: true,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _DoctorsTab extends StatefulWidget {
  const _DoctorsTab({required this.store});
  final AppStore store;

  @override
  State<_DoctorsTab> createState() => _DoctorsTabState();
}

class _DoctorsTabState extends State<_DoctorsTab> {
  String _q = '';

  bool _dupDoctor(BuildContext context, String name, String? exceptId) {
    final n = name.trim().toLowerCase();
    final dup = widget.store.doctors
        .any((x) => x.id != exceptId && x.name.trim().toLowerCase() == n);
    if (dup) {
      showSnack(context, tr('الدكتور ده موجود في القايمة بالفعل', 'This doctor is already in the list'));
    }
    return dup;
  }

  Future<void> _editDoctor(BuildContext context, Doctor d) async {
    final r = await _twoFieldDialog(context,
        title: tr('تعديل الدكتور', 'Edit doctor'),
        label1: tr('اسم الدكتور', 'Doctor name'),
        label2: tr('التخصص (اختياري)', 'Specialty (optional)'),
        value1: d.name,
        value2: d.specialty,
        label3: tr('رقم التليفون (واتساب)', 'Phone number (WhatsApp)'),
        value3: d.phone,
        keyboard3: TextInputType.phone);
    if (r == null || !context.mounted) return;
    final pk = _phoneKey(r[2]);
    if (pk.isNotEmpty) {
      for (final x in widget.store.doctors) {
        if (x.id != d.id && x.phone.isNotEmpty && _phoneKey(x.phone) == pk) {
          await _alreadyExistsDialog(context, x);
          return;
        }
      }
    }
    if (_dupDoctor(context, r[0], d.id)) return;
    widget.store.saveDoctor(d.copyWith(name: r[0], specialty: r[1], phone: r[2]));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final isAdmin = widget.store.user.isAdmin;
        final q = _normName(_q);
        final list = widget.store.doctors
            .where((d) =>
                q.isEmpty ||
                _normName(d.name).contains(q) ||
                _normName(d.specialty).contains(q))
            .toList();
        return Column(
          children: [
            _SearchField(onChanged: (v) => setState(() => _q = v)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  final r = await _twoFieldDialog(context,
                      title: tr('دكتور جديد', 'New doctor'),
                      label1: tr('اسم الدكتور', 'Doctor name'),
                      label2: tr('التخصص (اختياري)', 'Specialty (optional)'),
                      label3: tr('رقم التليفون (واتساب)', 'Phone number (WhatsApp)'),
                      keyboard3: TextInputType.phone);
                  if (r == null || !context.mounted) return;
                  // 1) التليفون مفتاح منع التكرار: نفس الرقم = نفس الدكتور
                  final pk = _phoneKey(r[2]);
                  if (pk.isNotEmpty) {
                    for (final x in widget.store.doctors) {
                      if (x.phone.isNotEmpty && _phoneKey(x.phone) == pk) {
                        await _alreadyExistsDialog(context, x);
                        return;
                      }
                    }
                  }
                  // 2) نفس الاسم بالظبط
                  if (_dupDoctor(context, r[0], null)) return;
                  // 3) أسماء قريبة: تختار من الموجود أو تؤكد الإضافة
                  final near = widget.store.doctors
                      .where((x) => _nameSimilar(x.name, r[0]))
                      .take(5)
                      .toList();
                  if (near.isNotEmpty) {
                    final proceed = await _nearMatchesDialog(context, near);
                    if (proceed != true || !context.mounted) return;
                  }
                  widget.store.saveDoctor(Doctor(
                      id: widget.store.newId(),
                      name: r[0],
                      specialty: r[1],
                      phone: r[2]));
                },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(tr('إضافة دكتور', 'Add doctor')),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? (widget.store.doctors.isEmpty
                      ? EmptyState(
                          icon: Icons.person_off_rounded,
                          title: tr('مفيش دكاترة', 'No doctors'),
                          subtitle: tr('ضيف أول دكتور من الزرار اللي فوق', 'Add your first doctor with the button above'))
                      : EmptyState(
                          icon: Icons.search_off_rounded,
                          title: tr('مفيش نتائج مطابقة', 'No matching results'),
                          subtitle: tr('جرّب اسم تاني', 'Try a different name')))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final d = list[i];
                        return FadeSlideIn(
                          index: i,
                          child: Card(
                          child: ListTile(
                            leading: InitialAvatar(d.name, size: 42),
                            title: Text(d.name,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (d.specialty.isNotEmpty) Text(d.specialty),
                                if (d.phone.isNotEmpty)
                                  Text(d.phone,
                                      textDirection: TextDirection.ltr),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ContactButtons(phone: d.phone, compact: true),
                                if (isAdmin && d.phone.isEmpty)
                                  IconButton(
                                    tooltip: tr('إضافة رقم تليفون', 'Add phone number'),
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.add_call,
                                        color: Color(0xFF1FAF54)),
                                    onPressed: () => _editDoctor(context, d),
                                  ),
                                if (isAdmin)
                                _RowMenu(
                              onEdit: () => _editDoctor(context, d),
                              onDelete: () async {
                                if (await confirmDelete(
                                    context, tr('تمسح ${d.name} من القايمة؟', 'Remove ${d.name} from the list?'))) {
                                  widget.store.deleteDoctor(d.id);
                                }
                              },
                            ),
                              ],
                            ),
                          ),
                        ));
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MedicinesTab extends StatefulWidget {
  const _MedicinesTab({required this.store});
  final AppStore store;

  @override
  State<_MedicinesTab> createState() => _MedicinesTabState();
}

class _MedicinesTabState extends State<_MedicinesTab> {
  String _q = '';

  bool _dupMedicine(BuildContext context, String name, String? exceptId) {
    final n = name.trim().toLowerCase();
    final dup = widget.store.medicines
        .any((x) => x.id != exceptId && x.name.trim().toLowerCase() == n);
    if (dup) {
      showSnack(context, tr('الدوا ده موجود في القايمة بالفعل', 'This medicine is already in the list'));
    }
    return dup;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final isAdmin = widget.store.user.isAdmin;
        final q = _normName(_q);
        final list = widget.store.medicines
            .where((m) =>
                q.isEmpty ||
                _normName(m.name).contains(q) ||
                _normName(m.form).contains(q))
            .toList();
        return Column(
          children: [
            _SearchField(onChanged: (v) => setState(() => _q = v)),
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () async {
                    final m = await showMedicineForm(context, widget.store);
                    if (m == null) return;
                    if (context.mounted && _dupMedicine(context, m.name, null)) return;
                    widget.store.saveMedicine(m);
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: Text(tr('إضافة دوا', 'Add medicine')),
                ),
              ),
            Expanded(
              child: list.isEmpty
                  ? (widget.store.medicines.isEmpty
                      ? EmptyState(
                          icon: Icons.medication_rounded,
                          title: tr('مفيش أدوية', 'No medicines'),
                          subtitle: tr('ضيف أول دوا من الزرار اللي فوق', 'Add your first medicine with the button above'))
                      : EmptyState(
                          icon: Icons.search_off_rounded,
                          title: tr('مفيش نتائج مطابقة', 'No matching results'),
                          subtitle: tr('جرّب اسم تاني', 'Try a different name')))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final m = list[i];
                        return FadeSlideIn(
                          index: i,
                          child: Card(
                          child: ListTile(
                            leading: MedicineThumb(m),
                            title: Text(m.name,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text([
                              if (m.form.isNotEmpty) m.form,
                              if (m.price > 0) formatMoney(m.price),
                            ].join('  •  ')),
                            trailing: !isAdmin ? null : _RowMenu(
                              onEdit: () async {
                                final u = await showMedicineForm(context, widget.store,
                                    existing: m);
                                if (u == null) return;
                                if (context.mounted && _dupMedicine(context, u.name, m.id)) return;
                                widget.store.saveMedicine(u);
                              },
                              onDelete: () async {
                                if (await confirmDelete(
                                    context, tr('تمسح ${m.name} من القايمة؟', 'Remove ${m.name} from the list?'))) {
                                  widget.store.deleteMedicine(m.id);
                                }
                              },
                            ),
                          ),
                        ));
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded),
        onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(tr('تعديل', 'Edit'))),
          PopupMenuItem(value: 'delete', child: Text(tr('حذف', 'Delete'))),
        ],
      );
}
