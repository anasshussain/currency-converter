import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../converter/presentation/providers/converter_provider.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../../domain/entities/rate_alert.dart';
import '../providers/alerts_provider.dart';
import '../widgets/add_alert_sheet.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final alerts = ref.watch(alertsProvider);
    final input = ref.watch(converterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Alerts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddAlertSheet(context, from: input.from, to: input.to),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New alert'),
      ),
      body: alerts.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No alerts yet',
              subtitle: 'Create an alert and the app will tell you when a '
                  'rate reaches your target.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                for (final alert in alerts) ...[
                  _AlertCard(alert: alert),
                  const SizedBox(height: 10),
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Alerts are checked every time rates refresh while the '
                    'app is open.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.muted, fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AlertCard extends ConsumerWidget {
  const _AlertCard({required this.alert});

  final RateAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final from = ref.watch(currencyProvider(alert.from));
    final current = ref.watch(pairRateProvider((from: alert.from, to: alert.to)));

    final String status;
    if (alert.triggeredAt != null) {
      status = 'Triggered ${Formatters.relativeTime(alert.triggeredAt!)}';
    } else {
      status = alert.isActive ? 'Active' : 'Paused';
    }

    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(alertsProvider.notifier).remove(alert.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      child: AppCard(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            CurrencyAvatar(currency: from, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${alert.from} → ${alert.to}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${alert.triggerWhenAbove ? 'Above' : 'Below'} '
                    '${Formatters.rate(alert.target)}'
                    '${current == null ? '' : '  ·  now ${Formatters.rate(current)}'}',
                    style: TextStyle(color: p.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: alert.triggeredAt != null
                          ? AppColors.success
                          : (alert.isActive ? AppColors.primary : p.muted),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: alert.isActive,
              activeTrackColor: AppColors.primary,
              onChanged: (value) => ref
                  .read(alertsProvider.notifier)
                  .setActive(alert.id, active: value),
            ),
          ],
        ),
      ),
    );
  }
}
