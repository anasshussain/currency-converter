import '../entities/exchange_rates.dart';

/// Pure conversion logic, no I/O.
class ConvertCurrency {
  const ConvertCurrency();

  double? call({
    required ExchangeRates rates,
    required double amount,
    required String from,
    required String to,
  }) {
    return rates.convert(amount, from, to);
  }
}
