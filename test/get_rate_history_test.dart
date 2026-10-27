import 'package:currency_converter/core/error/failure.dart';
import 'package:currency_converter/features/rates/domain/entities/exchange_rates.dart';
import 'package:currency_converter/features/rates/domain/entities/rate_point.dart';
import 'package:currency_converter/features/rates/domain/repositories/rates_repository.dart';
import 'package:currency_converter/features/rates/domain/usecases/get_daily_change.dart';
import 'package:currency_converter/features/rates/domain/usecases/get_rate_history.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements RatesRepository {
  _FakeRepository(this.onHistory);

  final Map<String, double>? Function(DateTime date) onHistory;

  @override
  Future<ExchangeRates> getLatestRates({bool forceRefresh = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, double>?> getHistoricalRates(DateTime date) async {
    return onHistory(date);
  }
}

void main() {
  final latest = ExchangeRates(
    base: 'USD',
    rates: const {'USD': 1, 'PKR': 281},
    dataDate: DateTime.utc(2026, 10, 27),
    fetchedAt: DateTime.utc(2026, 10, 27, 7),
  );

  test('builds ordered points and ends with the live rate', () async {
    final repo = _FakeRepository((_) => {'USD': 1, 'PKR': 280});
    final points = await GetRateHistory(repo)(
      latest: latest,
      from: 'USD',
      to: 'PKR',
      range: ChartRange.week,
    );

    expect(points.length, ChartRange.week.points);
    expect(points.last.value, 281);
    expect(points.first.value, 280);
    expect(
      points.map((p) => p.date).toList(),
      orderedEquals([...points.map((p) => p.date)]..sort()),
    );
  });

  test('skips days the provider has no snapshot for', () async {
    final repo = _FakeRepository(
      (date) => date.day.isEven ? null : {'USD': 1, 'PKR': 279},
    );
    final points = await GetRateHistory(repo)(
      latest: latest,
      from: 'USD',
      to: 'PKR',
      range: ChartRange.week,
    );
    expect(points.length, lessThan(ChartRange.week.points));
    expect(points.length, greaterThanOrEqualTo(2));
  });

  test('throws when no history is available', () async {
    final repo = _FakeRepository((_) => null);
    expect(
      () => GetRateHistory(repo)(
        latest: latest.copyWith(),
        from: 'USD',
        to: 'XXX',
        range: ChartRange.week,
      ),
      throwsA(isA<Failure>()),
    );
  });

  test('daily change compares with the previous day', () async {
    final repo = _FakeRepository((_) => {'USD': 1, 'PKR': 280});
    final change = await GetDailyChange(repo)(
      latest: latest,
      from: 'USD',
      to: 'PKR',
    );
    expect(change, closeTo((281 / 280 - 1) * 100, 0.0001));
  });
}
