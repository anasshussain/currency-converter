import 'package:currency_converter/features/rates/domain/entities/exchange_rates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rates = ExchangeRates(
    base: 'USD',
    rates: const {'USD': 1, 'PKR': 281.235, 'EUR': 0.92},
    dataDate: DateTime.utc(2026, 10, 27),
    fetchedAt: DateTime.utc(2026, 10, 27, 7),
  );

  test('converts from the base currency', () {
    expect(rates.convert(100, 'USD', 'PKR'), closeTo(28123.5, 0.001));
  });

  test('converts between two non-base currencies via the base', () {
    expect(rates.rate('EUR', 'PKR'), closeTo(305.69, 0.01));
  });

  test('returns null for unsupported currencies', () {
    expect(rates.rate('USD', 'XXX'), isNull);
    expect(rates.convert(10, 'XXX', 'USD'), isNull);
  });

  test('copyWith only changes the stale flag', () {
    final stale = rates.copyWith(isStale: true);
    expect(stale.isStale, isTrue);
    expect(stale.rates, rates.rates);
  });
}
