import 'dart:typed_data';

import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';
import 'package:pharma_orders/core/l10n/lang.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:pharma_orders/app/app_store.dart';
import 'package:pharma_orders/features/statistics/domain/usecases/order_stats.dart';
import 'package:pharma_orders/features/statistics/data/orders_excel_exporter.dart';
import 'package:pharma_orders/core/widgets/common.dart';
import 'package:pharma_orders/core/widgets/motion.dart';

enum _Metric { value, items, orders }

/// داشبورد الأدمن (رئيس المبيعات): كل مبيعات كل المناديب + مؤشر شهري.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key, required this.store, this.trailing});

  final AppStore store;
  final Widget? trailing;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  _Metric _metric = _Metric.value;

  Future<void> _exportExcel(BuildContext context) async {
    if (widget.store.orders.isEmpty) {
      showSnack(context, tr('مفيش طلبيات للتصدير لسه', 'No orders to export yet'));
      return;
    }
    try {
      final bytes = buildOrdersExcel(widget.store.orders);
      final name =
          'pharmify_orders_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      await SharePlus.instance.share(ShareParams(files: [
        XFile.fromData(Uint8List.fromList(bytes),
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            name: name),
      ]));
    } catch (_) {
      if (context.mounted) {
        showSnack(context, tr('حصلت مشكلة في التصدير', 'Export failed'));
      }
    }
  }

  double _pick(MonthStat m) => switch (_metric) {
        _Metric.value => m.value,
        _Metric.items => m.items.toDouble(),
        _Metric.orders => m.orders.toDouble(),
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final all = widget.store.orders;
        final months = monthlyStats(all);
        final cur = months.last;
        final prev = months[months.length - 2];
        final curOrders = ordersInMonth(all, cur.month);
        final activeReps = curOrders.map((o) => o.repId).toSet().length;
        final monthName = latinDigits(DateFormat('MMMM y', lang.code).format(cur.month));

        double? delta;
        if (prev.value > 0) delta = (cur.value - prev.value) / prev.value * 100;

        // لو مفيش أسعار في الأدوية، الترتيب بالعبوات بدل القيمة (غير كده كله أصفار)
        final byMoney = curOrders.any((o) => o.totalValue > 0);

        // خرائط توزيع كاملة (مش بس توب 5) علشان النسب تطلع من الإجمالي الحقيقي
        final repsMap = <String, double>{};
        for (final o in curOrders) {
          final k = o.repName.isEmpty ? tr('بدون اسم', 'No name') : o.repName;
          repsMap[k] = (repsMap[k] ?? 0) + (byMoney ? o.totalValue : o.totalQuantity.toDouble());
        }
        final medsMap = <String, double>{};
        for (final o in curOrders) {
          for (final i in o.items) {
            medsMap[i.medicineName] =
                (medsMap[i.medicineName] ?? 0) + (byMoney ? i.total : i.quantity.toDouble());
          }
        }
        final docsMap = <String, double>{};
        for (final o in curOrders) {
          docsMap[o.doctorName] =
              (docsMap[o.doctorName] ?? 0) + (byMoney ? o.totalValue : o.totalQuantity.toDouble());
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              title: tr('إحصائيات رئيس المبيعات', 'Sales head statistics'),
              subtitle: monthName,
              trailing: widget.trailing,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الرقم الأساسي
                  FadeSlideIn(
                      child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('مبيعات الشهر', 'This month\'s sales'),
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          CountUp(
                            value: cur.value,
                            builder: (context, v) => Text(formatMoney(v),
                                style: const TextStyle(
                                    fontSize: 34, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 8),
                          if (delta != null)
                            _DeltaChip(delta: delta)
                          else
                            Text(tr('مفيش مبيعات الشهر اللي فات للمقارنة', 'No sales last month to compare'),
                                style: TextStyle(
                                    color: scheme.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    index: 1,
                    child: Row(
                    children: [
                      Expanded(
                          child: _Mini(
                              icon: Icons.receipt_long_rounded,
                              value: formatNum(cur.orders),
                              label: tr('طلبيات', 'Orders'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _Mini(
                              icon: Icons.inventory_2_rounded,
                              value: formatNum(cur.items),
                              label: tr('عبوات', 'Packs'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _Mini(
                              icon: Icons.badge_rounded,
                              value: '$activeReps',
                              label: tr('مناديب نشطين', 'Active reps'))),
                    ],
                  )),
                  const SizedBox(height: 12),
                  // تصدير الطلبيات إكسيل (أدمن بس)
                  if (widget.store.user.isAdmin)
                    FadeSlideIn(
                      index: 2,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48)),
                          onPressed: () => _exportExcel(context),
                          icon: const Icon(Icons.file_download_rounded),
                          label: Text(tr('تصدير كل الطلبيات Excel',
                              'Export all orders to Excel')),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // الرسم البياني الشهري
                  FadeSlideIn(
                    index: 2,
                    child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('المبيعات شهر بشهر', 'Sales month by month'),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<_Metric>(
                              showSelectedIcon: false,
                              style: ButtonStyle(
                                  visualDensity: VisualDensity.compact),
                              segments: [
                                ButtonSegment(
                                    value: _Metric.value, label: Text(tr('القيمة', 'Value'))),
                                ButtonSegment(
                                    value: _Metric.items, label: Text(tr('العبوات', 'Packs'))),
                                ButtonSegment(
                                    value: _Metric.orders, label: Text(tr('الطلبيات', 'Orders'))),
                              ],
                              selected: {_metric},
                              onSelectionChanged: (s) =>
                                  setState(() => _metric = s.first),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _MonthChart(months: months, pick: _pick),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                  if (curOrders.isEmpty)
                    SizedBox(
                      height: 200,
                      child: EmptyState(
                        icon: Icons.pie_chart_rounded,
                        title: tr('مفيش مبيعات الشهر ده لسه', 'No sales this month yet'),
                        subtitle: tr('أول ما المناديب يسجلوا طلبيات هتظهر هنا', 'Orders will show here once reps log them'),
                      ),
                    )
                  else ...[
                    FadeSlideIn(
                      index: 3,
                      child: _DonutCard(
                          title: tr('توزيع المبيعات على المناديب', 'Sales share by rep'),
                          data: repsMap,
                          money: byMoney)),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 4,
                      child: _DonutCard(
                          title: tr('توزيع المبيعات على الأدوية', 'Sales share by medicine'),
                          data: medsMap,
                          money: byMoney)),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 5,
                      child: _DonutCard(
                          title: tr('توزيع الطلبيات على الدكاترة', 'Orders share by doctor'),
                          data: docsMap,
                          money: byMoney)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});
  final double delta;

  @override
  Widget build(BuildContext context) {
    final up = delta >= 0;
    final color = up ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color, size: 18),
        const SizedBox(width: 4),
        Text(
            tr('${up ? '+' : ''}${delta.toStringAsFixed(0)}% عن الشهر اللي فات', '${up ? '+' : ''}${delta.toStringAsFixed(0)}% vs last month'),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

/// رسم الأعمدة الشهري (القيمة/العبوات/الطلبيات) بمكتبة fl_chart.
class _MonthChart extends StatelessWidget {
  const _MonthChart({required this.months, required this.pick});
  final List<MonthStat> months;
  final double Function(MonthStat) pick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxV = months.fold<double>(0, (m, x) => pick(x) > m ? pick(x) : m);
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxV == 0 ? 1 : maxV * 1.15,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= months.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      latinDigits(DateFormat('MMM', lang.code).format(months[i].month)),
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < months.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: pick(months[i]),
                    width: 16,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                    // الشهر الحالي بلون أساسي والقديم باهت
                    color: i == months.length - 1
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: 0.35),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// ألوان أقسام الدونات
const _palette = [
  Color(0xFF0B7A75),
  Color(0xFFE08A1E),
  Color(0xFF6A5ACD),
  Color(0xFF2E7D32),
  Color(0xFFC2185B),
  Color(0xFF90A4AE), // "أخرى"
];

/// كارت دونات: توزيع نسبة كل عنصر من الإجمالي + مفتاح الألوان تحته.
class _DonutCard extends StatelessWidget {
  const _DonutCard({required this.title, required this.data, required this.money});
  final String title;
  final Map<String, double> data;
  final bool money;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = data.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) return const SizedBox.shrink();

    // توب 5 والباقي يتجمع في "أخرى" علشان النسب تفضل صح
    final top = sorted.take(5).toList();
    final restValue = sorted.skip(5).fold<double>(0, (s, e) => s + e.value);
    final slices = [
      ...top,
      if (restValue > 0) MapEntry(tr('أخرى', 'Others'), restValue),
    ];
    final total = slices.fold<double>(0, (s, e) => s + e.value);

    String fmt(double v) => money ? formatMoney(v) : formatNum(v.round());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: [
                    for (var i = 0; i < slices.length; i++)
                      PieChartSectionData(
                        value: slices[i].value,
                        color: _palette[i % _palette.length],
                        radius: 52,
                        showTitle:
                            total > 0 && slices[i].value / total >= 0.08,
                        title:
                            '${(slices[i].value / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < slices.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _palette[i % _palette.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(slices[i].key,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${fmt(slices[i].value)}  ·  ${(slices[i].value / total * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
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
