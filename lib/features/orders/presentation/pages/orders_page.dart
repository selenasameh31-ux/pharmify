import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';

import 'package:pharma_orders/app/app_store.dart';
import 'package:pharma_orders/features/orders/domain/entities/order.dart';
import 'package:pharma_orders/core/theme/app_theme.dart';
import 'package:pharma_orders/core/widgets/common.dart';
import 'package:pharma_orders/core/widgets/motion.dart';
import 'package:pharma_orders/core/utils/invoice_share.dart';
import 'package:pharma_orders/core/widgets/contact_buttons.dart';
import 'package:pharma_orders/features/orders/presentation/pages/order_form_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.store, this.trailing});

  final AppStore store;
  final Widget? trailing;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _query = '';

  // بحث متسامح: بيتجاهل الحروف الكبيرة والتشكيل والفرق بين أ/إ/ا وة/ه وي/ى
  String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[\u064B-\u0652\u0640]'), '')
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final all = widget.store.orders;
        final q = _query.trim();
        final orders = all.where((o) => q.isEmpty || _norm(o.doctorName).contains(_norm(q))).toList();
        final today = all.where((o) => _sameDay(o.createdAt, DateTime.now())).toList();
        final todayItems = today.fold<int>(0, (s, o) => s + o.totalQuantity);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(context, today.length, todayItems)),
            if (widget.store.showSync)
              SliverToBoxAdapter(child: _SyncBanner(pending: widget.store.pendingCount)),
            if (orders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: q.isEmpty
                      ? Icons.receipt_long_rounded
                      : Icons.search_off_rounded,
                  title: q.isEmpty ? tr('لسه مفيش طلبيات', 'No orders yet') : tr('مفيش طلبيات للدكتور ده', 'No orders for this doctor'),
                  subtitle: q.isEmpty
                      ? tr('دوس "طلبية جديدة" واختار الدكتور والأدوية', 'Tap "New order" and choose the doctor and medicines')
                      : tr('جرّب اسم تاني', 'Try another name'),
                ),
              )
            else
              ..._groupedSlivers(context, orders),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context, int todayCount, int todayItems) {
    final scheme = Theme.of(context).colorScheme;
    final isAdmin = widget.store.user.isAdmin;
    return GradientHeader(
      title: isAdmin ? tr('كل الطلبيات', 'All orders') : tr('طلبيات المندوب', 'Rep orders'),
      subtitle: tr('النهارده: $todayCount طلبية، $todayItems عبوة', 'Today: $todayCount order(s), $todayItems pack(s)'),
      trailing: widget.trailing,
      child: Padding(
        padding: const EdgeInsets.only(right: 0, left: 0),
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: tr('ابحث باسم الدكتور', 'Search by doctor name'),
            prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _groupedSlivers(BuildContext context, List<Order> orders) {
    final widgets = <Widget>[];
    DateTime? current;
    var n = 0;
    for (final o in orders) {
      if (current == null || !_sameDay(current, o.createdAt)) {
        current = o.createdAt;
        final dayTotal = orders.where((x) => _sameDay(x.createdAt, o.createdAt)).length;
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
          child: Row(
            children: [
              Text(formatDay(o.createdAt),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('($dayTotal)',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ));
      }
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: FadeSlideIn(
            index: n++, child: _OrderCard(order: o, store: widget.store)),
      ));
    }
    return [
      SliverList(delegate: SliverChildListDelegate(widgets)),
    ];
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.store});

  final Order order;
  final AppStore store;

  String _phoneOf(Order o) {
    for (final d in store.doctors) {
      if (d.id == o.doctorId) return d.phone;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OrderFormPage(store: store, existing: order),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialAvatar(order.doctorName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.doctorName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                            store.user.isAdmin && order.repName.isNotEmpty
                                ? '${formatTime(order.createdAt)}  •  ${tr('المندوب', 'Rep')}: ${order.repName}'
                                : formatTime(order.createdAt),
                            style: TextStyle(
                                color: scheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (v) async {
                      if (v == 'invoice') {
                        await shareInvoice(context, order);
                      } else if (v == 'wa') {
                        final lines = [
                          tr('طلبية ${order.doctorName}', 'Order for ${order.doctorName}'),
                          for (final it in order.items) '- ${it.medicineName} x${it.quantity}',
                          tr('إجمالي العبوات: ${order.totalQuantity}', 'Total packs: ${order.totalQuantity}'),
                          if (order.totalValue > 0) '${tr('الإجمالي', 'Total')}: ${formatMoney(order.totalValue)}',
                        ];
                        await openWhatsApp(context, _phoneOf(order), text: lines.join('\n'));
                      } else if (v == 'edit') {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              OrderFormPage(store: store, existing: order),
                        ));
                      } else {
                        final ok = await confirmDelete(
                            context, tr('متأكد إنك عايز تمسح طلبية ${order.doctorName}؟', 'Delete the order for ${order.doctorName}?'));
                        if (ok) {
                          store.deleteOrder(order.id);
                          if (context.mounted) showSnack(context, tr('تم حذف الطلبية', 'Order deleted'));
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      if (_phoneOf(order).isNotEmpty)
                        PopupMenuItem(
                            value: 'wa',
                            child: Row(children: [
                              const Icon(Icons.chat_rounded,
                                  size: 20, color: Color(0xFF1FAF54)),
                              const SizedBox(width: 10),
                              Text(tr('إرسال على واتساب', 'Send on WhatsApp')),
                            ])),
                      PopupMenuItem(
                          value: 'invoice',
                          child: Row(children: [
                            Icon(Icons.picture_as_pdf_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(tr('فاتورة PDF', 'PDF invoice')),
                          ])),
                      PopupMenuItem(value: 'edit', child: Text(tr('تعديل', 'Edit'))),
                      PopupMenuItem(value: 'delete', child: Text(tr('حذف', 'Delete'))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final it in order.items)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${it.medicineName}  ×${it.quantity}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.onPrimaryContainer)),
                    ),
                ],
              ),
              if (order.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.sticky_note_2_outlined,
                        size: 16, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(order.notes,
                          style: TextStyle(
                              color: scheme.onSurfaceVariant, fontSize: 13)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        order.totalValue > 0
                            ? tr('الإجمالي: ${order.totalQuantity} عبوة  •  ${formatMoney(order.totalValue)}', 'Total: ${order.totalQuantity} packs  •  ${formatMoney(order.totalValue)}')
                            : tr('الإجمالي: ${order.totalQuantity} عبوة', 'Total: ${order.totalQuantity} packs'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: scheme.primary)),
                  ),
                  if (store.showSync) _SyncChip(pending: order.pending),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncChip extends StatelessWidget {
  const _SyncChip({required this.pending});
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final color = pending ? const Color(0xFFB26A00) : const Color(0xFF2E7D32);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(pending),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(pending ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
              size: 15, color: color),
          const SizedBox(width: 4),
          Text(pending ? tr('مستنية النت', 'Waiting for internet') : tr('اتزامنت', 'Synced'),
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.pending});
  final int pending;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: pending == 0
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.warnBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Icon(Icons.cloud_off_rounded, color: context.warnIcon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      tr('$pending طلبية متسجلة على الجهاز، هتتبعت لوحدها أول ما النت يرجع', '$pending orders saved on this device, they will sync automatically when the internet is back'),
                      style: TextStyle(
                          color: context.warnFg, fontSize: 13)),
                ),
              ]),
            ),
    );
  }
}
