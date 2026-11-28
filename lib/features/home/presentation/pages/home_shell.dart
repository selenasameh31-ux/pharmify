import 'package:material_ui/material_ui.dart';
import 'package:pharma_orders/core/l10n/lang.dart';

import 'package:pharma_orders/app/app_store.dart';
import 'package:pharma_orders/core/widgets/common.dart';
import 'package:pharma_orders/features/statistics/presentation/pages/statistics_page.dart';
import 'package:pharma_orders/features/catalog/presentation/pages/lists_page.dart';
import 'package:pharma_orders/features/orders/presentation/pages/order_form_page.dart';
import 'package:pharma_orders/features/orders/presentation/pages/orders_page.dart';
import 'package:pharma_orders/features/orders/presentation/pages/summary_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.store,
    required this.onSignOut,
    this.isDemo = false,
  });

  final AppStore store;
  final VoidCallback onSignOut;
  final bool isDemo;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _newOrder() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OrderFormPage(store: widget.store),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final user = store.user;
    final account = AccountButton(
      name: user.name,
      email: user.email,
      isAdmin: user.isAdmin,
      onSignOut: widget.onSignOut,
    );

    // الأدمن: داشبورد، كل الطلبيات، القوائم. المندوب: طلبياته، ملخصه، القوائم.
    final tabs = user.isAdmin
        ? <_Tab>[
            _Tab(tr('الإحصائيات', 'Statistics'), Icons.dashboard_outlined, Icons.dashboard_rounded,
                StatisticsPage(store: store, trailing: account)),
            _Tab(tr('الطلبيات', 'Orders'), Icons.receipt_long_outlined, Icons.receipt_long_rounded,
                OrdersPage(store: store, trailing: account)),
            _Tab(tr('القوائم', 'Lists'), Icons.medical_services_outlined,
                Icons.medical_services_rounded,
                ListsPage(store: store, trailing: account)),
          ]
        : <_Tab>[
            _Tab(tr('الطلبيات', 'Orders'), Icons.receipt_long_outlined, Icons.receipt_long_rounded,
                OrdersPage(store: store, trailing: account)),
            _Tab(tr('ملخصي', 'My summary'), Icons.insights_outlined, Icons.insights_rounded,
                SummaryPage(store: store, trailing: account)),
            _Tab(tr('القوائم', 'Lists'), Icons.medical_services_outlined,
                Icons.medical_services_rounded,
                ListsPage(store: store, trailing: account)),
          ];
    final showFab = tabs[_index].label == tr('الطلبيات', 'Orders');

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        body: Column(
          children: [
            if (store.error != null)
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(store.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 13)),
                  ),
                ),
              ),
            Expanded(
              // تلاشي + انزلاق خفيف لما نغير التاب
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                            begin: const Offset(0, .03), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey('tab$_index'),
                  child: tabs[_index].page,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: AnimatedScale(
          scale: showFab ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: FloatingActionButton.extended(
            onPressed: showFab ? _newOrder : null,
            icon: const Icon(Icons.add_rounded),
            label: Text(tr('طلبية جديدة', 'New order'),
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final t in tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selectedIcon),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon, selectedIcon;
  final Widget page;
  _Tab(this.label, this.icon, this.selectedIcon, this.page);
}
