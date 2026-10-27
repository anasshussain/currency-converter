import '../entities/exchange_rates.dart';
import '../repositories/rates_repository.dart';

/// Percentage change of a pair versus the previous published day.
class GetDailyChange {
  const GetDailyChange(this._repository);

  final RatesRepository _repository;

  Future<double?> call({
    required ExchangeRates latest,
    required String from,
    required String to,
  }) async {
    final current = latest.rate(from, to);
    if (current == null) return null;

    final previousDate = latest.dataDate.subtract(const Duration(days: 1));
    final previous = await _repository.getHistoricalRates(previousDate);
    final fromRate = previous?[from];
    final toRate = previous?[to];
    if (fromRate == null || toRate == null || fromRate == 0 || toRate == 0) {
      return null;
    }

    final previousRate = toRate / fromRate;
    return (current / previousRate - 1) * 100;
  }
}
