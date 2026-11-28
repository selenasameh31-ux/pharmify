import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';

import 'package:pharma_orders/app/app_store.dart';
import 'package:pharma_orders/core/widgets/common.dart';
import 'package:pharma_orders/core/widgets/motion.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key, required this.store, this.trailing});

  final AppStore store;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final week = store.weekOrders;
        final totalItems = week.fold<int>(0, (s, o) => s + o.totalQuantity);

        final byDoctor = <String, int>{};
        final byMedicine = <String, int>{};
        for (final o in week) {
          byDoctor[o.doctorName] = (byDoctor[o.doctorName] ?? 0) + 1;
          for (final it in o.items) {
            byMedicine[it.medicineName] =
                (byMedicine[it.medicineName] ?? 0) + it.quantity;
          }
        }
        List<MapEntry<String, int>> top(Map<String, int> m) =>
            (m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
                .take(5)
                .toList();

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              title: tr('ملخصي الأسبوعي', 'My weekly summary'),
              subtitle: tr('آخر 7 أيام', 'Last 7 days'),
              trailing: trailing,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    child: Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              icon: Icons.storefront_rounded,
                              value: '${week.length}',
                              label: tr('زيارات / طلبيات', 'Visits / orders'))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              icon: Icons.inventory_2_rounded,
                              value: '$totalItems',
                              label: tr('إجمالي العبوات', 'Total packs'))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              icon: Icons.groups_rounded,
                              value: '${byDoctor.length}',
                              label: tr('دكاترة', 'Doctors'))),
                    ],
                  )),
                  const SizedBox(height: 24),
                  if (week.isEmpty)
                    SizedBox(
                      height: 260,
                      child: EmptyState(
                        icon: Icons.insights_rounded,
                        title: tr('مفيش طلبيات الأسبوع ده', 'No orders this week'),
                        subtitle: tr('أول ما تسجل طلبيات الأرقام هتظهر هنا', 'Numbers will show once you log orders'),
                      ),
                    )
                  else ...[
                    FadeSlideIn(
                        index: 1,
                        child: _Ranking(
                      title: tr('أكتر الدكاترة زيارةً', 'Most visited doctors'),
                      unit: tr('زيارة', 'visit(s)'),
                      entries: top(byDoctor),
                      color: scheme.primary,
                    )),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                        index: 2,
                        child: _Ranking(
                      title: tr('أكتر الأدوية طلبًا', 'Most ordered medicines'),
                      unit: tr('عبوة', 'pack(s)'),
                      entries: top(byMedicine),
                      color: const Color(0xFFE08A1E),
                    )),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value, label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Ranking extends StatelessWidget {
  const _Ranking({
    required this.title,
    required this.unit,
    required this.entries,
    required this.color,
  });

  final String title, unit;
  final List<MapEntry<String, int>> entries;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxV = entries.first.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            for (var i = 0; i < entries.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${i + 1}. ${entries[i].key}',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text('${entries[i].value} $unit',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: color)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: entries[i].value / maxV,
                        minHeight: 8,
                        color: color,
                        backgroundColor: color.withValues(alpha: .12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
