import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';

class SelectOption {
  final String id;
  final String title;
  final String subtitle;
  final Widget? leading;
  const SelectOption(this.id, this.title, [this.subtitle = '', this.leading]);
}

/// قائمة اختيار بالبحث. multi=true يعني اختيار أكتر من عنصر (للأدوية).
/// بترجّع مجموعة الـ ids المختارة، أو null لو اتقفلت من غير تأكيد.
Future<Set<String>?> showSelectSheet(
  BuildContext context, {
  required String title,
  required List<SelectOption> options,
  required bool multi,
  Set<String> initial = const {},
  String? emptyText,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _SelectSheet(
      title: title,
      options: options,
      multi: multi,
      initial: initial,
      emptyText: emptyText ?? tr('مفيش نتائج', 'No results'),
    ),
  );
}

class _SelectSheet extends StatefulWidget {
  const _SelectSheet({
    required this.title,
    required this.options,
    required this.multi,
    required this.initial,
    required this.emptyText,
  });

  final String title;
  final List<SelectOption> options;
  final bool multi;
  final Set<String> initial;
  final String emptyText;

  @override
  State<_SelectSheet> createState() => _SelectSheetState();
}

class _SelectSheetState extends State<_SelectSheet> {
  late final Set<String> _selected = {...widget.initial};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = _query.trim();
    final shown = widget.options
        .where((o) => q.isEmpty || o.title.contains(q) || o.subtitle.contains(q))
        .toList();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold)),
                  ),
                  if (widget.multi && _selected.isNotEmpty)
                    Chip(
                      label: Text(tr('${_selected.length} مختار', '${_selected.length} selected')),
                      backgroundColor: scheme.primaryContainer,
                      side: BorderSide.none,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: tr('ابحث بالاسم', 'Search by name'),
                  prefixIcon: Icon(Icons.search_rounded),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: shown.isEmpty
                  ? Center(child: Text(widget.emptyText))
                  : ListView.builder(
                      itemCount: shown.length,
                      itemBuilder: (_, i) {
                        final o = shown[i];
                        final on = _selected.contains(o.id);
                        return ListTile(
                          leading: o.leading,
                          title: Text(o.title,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: o.subtitle.isEmpty ? null : Text(o.subtitle),
                          trailing: widget.multi
                              ? Checkbox(
                                  value: on,
                                  onChanged: (_) => _toggle(o.id),
                                )
                              : (on
                                  ? Icon(Icons.check_circle_rounded,
                                      color: scheme.primary)
                                  : null),
                          onTap: () {
                            if (widget.multi) {
                              _toggle(o.id);
                            } else {
                              Navigator.pop(context, {o.id});
                            }
                          },
                        );
                      },
                    ),
            ),
            if (widget.multi)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: Text(tr('تم', 'Done')),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });
}
