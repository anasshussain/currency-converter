import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../alerts/domain/entities/rate_alert.dart';
import '../../../alerts/presentation/providers/alerts_provider.dart';
import '../../../converter/presentation/pages/home_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../rates/presentation/pages/rates_page.dart';
import '../../../settings/presentation/pages/more_page.dart';
import '../providers/shell_provider.dart';
import '../widget/glass_nav_bar.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _pages = <Widget>[
    HomePage(),
    RatesPage(),
    HistoryPage(),
    MorePage(),
  ];

  static const _items = <GlassNavItem>[
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    GlassNavItem(
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Rates',
    ),
    GlassNavItem(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    GlassNavItem(
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      label: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellIndexProvider);

    ref.listen<List<RateAlert>>(alertsProvider, (previous, next) {
      final alreadyTriggered = {
        for (final a in previous ?? const <RateAlert>[])
          if (a.triggeredAt != null) a.id,
      };
      for (final alert in next) {
        if (alert.triggeredAt == null || alreadyTriggered.contains(alert.id)) {
          continue;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rate alert: 1 ${alert.from} is now '
                  '${alert.triggerWhenAbove ? 'above' : 'below'} '
                  '${Formatters.rate(alert.target)} ${alert.to}',
            ),
          ),
        );
      }
    });

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: GlassNavBar(
        currentIndex: index,
        items: _items,
        onTap: (i) => ref.read(shellIndexProvider.notifier).state = i,
      ),
    );
  }
}