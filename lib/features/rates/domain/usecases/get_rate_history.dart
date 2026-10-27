import '../../../../core/error/failure.dart';
import '../entities/exchange_rates.dart';
import '../entities/rate_point.dart';
import '../repositories/rates_repository.dart';

/// Builds chart data for a currency pair by sampling the provider's daily
/// snapshots, then appends the current live rate as the final point.
class GetRateHistory {
  const GetRateHistory(this._repository);

  final RatesRepository _repository;

  Future<List<RatePoint>> call({
    required ExchangeRates latest,
    required String from,
    required String to,
    required ChartRange range,
  }) async {
    final today = DateTime.utc(
      latest.dataDate.year,
      latest.dataDate.month,
      latest.dataDate.day,
    );

    final offsets = _sampleOffsets(range);
    final snapshots = await Future.wait(
      offsets.map((offset) async {
        final date = today.subtract(Duration(days: offset));
        try {
          final rates = await _repository.getHistoricalRates(date);
          final fromRate = rates?[from];
          final toRate = rates?[to];
          if (fromRate == null || toRate == null || fromRate == 0) return null;
          return RatePoint(date: date, value: toRate / fromRate);
        } on Failure {
          return null;
        }
      }),
    );

    final points = snapshots.whereType<RatePoint>().toList();
    final current = latest.rate(from, to);
    if (current != null) {
      points.add(RatePoint(date: today, value: current));
    }

    if (points.length < 2) {
      throw const ServerFailure('Chart data is not available for this pair.');
    }
    return points;
  }

  /// Day offsets (oldest first) evenly spread across the range, excluding today.
  List<int> _sampleOffsets(ChartRange range) {
    final count = range.points - 1;
    final step = range.days / count;
    final offsets = <int>{};
    for (var i = 0; i < count; i++) {
      final offset = (range.days - i * step).round();
      if (offset >= 1) offsets.add(offset);
    }
    return offsets.toList();
  }
}
