import 'package:equatable/equatable.dart';

/// A snapshot of exchange rates, all expressed relative to [base].
class ExchangeRates extends Equatable {
  const ExchangeRates({
    required this.base,
    required this.rates,
    required this.dataDate,
    required this.fetchedAt,
    this.isStale = false,
  });

  final String base;

  /// Units of currency X per 1 [base].
  final Map<String, double> rates;

  /// Date the provider published these rates for.
  final DateTime dataDate;

  /// When this app downloaded them.
  final DateTime fetchedAt;

  /// True when the app is offline and shows previously saved rates.
  final bool isStale;

  bool supports(String code) => rates.containsKey(code);

  /// 1 [from] = ? [to]. Null if either currency is unavailable.
  double? rate(String from, String to) {
    final fromRate = rates[from];
    final toRate = rates[to];
    if (fromRate == null || toRate == null || fromRate == 0) return null;
    return toRate / fromRate;
  }

  double? convert(double amount, String from, String to) {
    final r = rate(from, to);
    return r == null ? null : amount * r;
  }

  ExchangeRates copyWith({bool? isStale}) {
    return ExchangeRates(
      base: base,
      rates: rates,
      dataDate: dataDate,
      fetchedAt: fetchedAt,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [base, rates, dataDate, fetchedAt, isStale];
}
