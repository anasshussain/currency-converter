import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../currencies/domain/entities/currency.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/exchange_rates.dart';
import '../../domain/entities/rate_point.dart';

class RatesNotifier extends AsyncNotifier<ExchangeRates> {
  @override
  Future<ExchangeRates> build() {
    final timer = Timer.periodic(
      AppConstants.autoRefresh,
      (_) => refresh(silent: true),
    );
    ref.onDispose(timer.cancel);

    return ref.read(getLatestRatesProvider)();
  }

  Future<void> refresh({bool silent = false}) async {
    final previous = state.valueOrNull;

    if (!silent) {
      state = const AsyncLoading<ExchangeRates>().copyWithPrevious(state);
    }

    final next = await AsyncValue.guard(
      () => ref.read(getLatestRatesProvider)(forceRefresh: true),
    );

    if (next.hasError && previous != null) {
      state = AsyncData(previous.copyWith(isStale: true));
    } else {
      state = next;
    }
  }
}

final ratesProvider = AsyncNotifierProvider<RatesNotifier, ExchangeRates>(
  RatesNotifier.new,
);

final availableCurrenciesProvider = Provider<List<Currency>>((ref) {
  final all = ref.watch(currencyRepositoryProvider).getAll();
  final rates = ref.watch(ratesProvider).valueOrNull;
  if (rates == null) return all;
  return all.where((c) => rates.supports(c.code)).toList();
});

final currencyProvider = Provider.family<Currency, String>(
  (ref, code) => ref.watch(currencyRepositoryProvider).getByCode(code),
);

final pairRateProvider = Provider.family<double?, CurrencyPair>((ref, pair) {
  final rates = ref.watch(ratesProvider).valueOrNull;
  return rates?.rate(pair.from, pair.to);
});

final dailyChangeProvider =
    FutureProvider.autoDispose.family<double?, CurrencyPair>((ref, pair) async {
  final latest = await ref.watch(ratesProvider.future);
  try {
    return await ref.read(getDailyChangeProvider)(
      latest: latest,
      from: pair.from,
      to: pair.to,
    );
  } on Failure {
    return null;
  }
});

typedef ChartQuery = ({String from, String to, ChartRange range});

final rateHistoryProvider =
    FutureProvider.autoDispose.family<List<RatePoint>, ChartQuery>(
  (ref, query) async {
    final latest = await ref.read(ratesProvider.future);
    return ref.read(getRateHistoryProvider)(
      latest: latest,
      from: query.from,
      to: query.to,
      range: query.range,
    );
  },
);
