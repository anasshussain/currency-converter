import '../entities/exchange_rates.dart';

abstract interface class RatesRepository {
  /// Latest rates. Serves a fresh cache when possible, falls back to the
  /// last saved rates (marked stale) when offline, throws a `Failure` when
  /// nothing is available.
  Future<ExchangeRates> getLatestRates({bool forceRefresh = false});

  /// Rates (relative to USD) published for [date], or null if the provider
  /// has no snapshot for that day.
  Future<Map<String, double>?> getHistoricalRates(DateTime date);
}
