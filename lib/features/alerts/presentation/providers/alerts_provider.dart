import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../rates/domain/entities/exchange_rates.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../../domain/entities/rate_alert.dart';

/// Stores rate alerts and checks them every time new rates arrive.
/// A triggered alert is switched off and stamped with `triggeredAt`.
class AlertsNotifier extends Notifier<List<RateAlert>> {
  @override
  List<RateAlert> build() {
    ref.listen<AsyncValue<ExchangeRates>>(ratesProvider, (_, next) {
      final rates = next.valueOrNull;
      if (rates != null && !rates.isStale) _evaluate(rates);
    });
    return ref.read(alertsRepositoryProvider).getAll();
  }

  Future<void> add({
    required String from,
    required String to,
    required double target,
    required bool triggerWhenAbove,
  }) {
    final alert = RateAlert(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      from: from,
      to: to,
      target: target,
      triggerWhenAbove: triggerWhenAbove,
    );
    return _commit([alert, ...state]);
  }

  Future<void> remove(String id) {
    return _commit(state.where((a) => a.id != id).toList());
  }

  /// Re-arms an alert (or pauses an active one).
  Future<void> setActive(String id, {required bool active}) {
    return _commit([
      for (final a in state)
        if (a.id == id)
          RateAlert(
            id: a.id,
            from: a.from,
            to: a.to,
            target: a.target,
            triggerWhenAbove: a.triggerWhenAbove,
            isActive: active,
          )
        else
          a,
    ]);
  }

  void _evaluate(ExchangeRates rates) {
    var changed = false;
    final next = <RateAlert>[];

    for (final alert in state) {
      final current = rates.rate(alert.from, alert.to);
      if (alert.isActive && current != null && alert.isMet(current)) {
        next.add(alert.copyWith(isActive: false, triggeredAt: DateTime.now()));
        changed = true;
      } else {
        next.add(alert);
      }
    }

    if (changed) _commit(next);
  }

  Future<void> _commit(List<RateAlert> next) async {
    state = next;
    await ref.read(alertsRepositoryProvider).saveAll(next);
  }
}

final alertsProvider = NotifierProvider<AlertsNotifier, List<RateAlert>>(
  AlertsNotifier.new,
);
