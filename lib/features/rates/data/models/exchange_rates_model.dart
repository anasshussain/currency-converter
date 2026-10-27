import '../../../../core/error/failure.dart';
import '../../domain/entities/exchange_rates.dart';

class ExchangeRatesModel extends ExchangeRates {
  const ExchangeRatesModel({
    required super.base,
    required super.rates,
    required super.dataDate,
    required super.fetchedAt,
    super.isStale,
  });

  /// fawazahmed0/exchange-api: `{"date": "2026-10-27", "usd": {"pkr": 281.2, ...}}`
  factory ExchangeRatesModel.fromFawaz(
    Map<String, dynamic> json, {
    required DateTime fetchedAt,
  }) {
    final rates = parseFawazRates(json);
    return ExchangeRatesModel(
      base: 'USD',
      rates: rates,
      dataDate: _parseDate(json['date']) ?? fetchedAt.toUtc(),
      fetchedAt: fetchedAt,
    );
  }

  /// open.er-api.com: `{"result": "success", "time_last_update_unix": ..., "rates": {...}}`
  factory ExchangeRatesModel.fromErApi(
    Map<String, dynamic> json, {
    required DateTime fetchedAt,
  }) {
    final raw = json['rates'];
    if (json['result'] != 'success' || raw is! Map) {
      throw const ServerFailure('Malformed rates response.');
    }
    final rates = <String, double>{};
    raw.forEach((key, value) {
      if (value is num && value > 0) {
        rates[(key as String).toUpperCase()] = value.toDouble();
      }
    });
    rates['USD'] = 1;

    final unix = json['time_last_update_unix'];
    final updated = unix is int
        ? DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true)
        : fetchedAt.toUtc();

    return ExchangeRatesModel(
      base: 'USD',
      rates: rates,
      dataDate: updated,
      fetchedAt: fetchedAt,
    );
  }

  factory ExchangeRatesModel.fromCacheJson(Map<String, dynamic> json) {
    final raw = json['rates'] as Map<String, dynamic>;
    return ExchangeRatesModel(
      base: json['base'] as String,
      rates: raw.map((key, value) => MapEntry(key, (value as num).toDouble())),
      dataDate: DateTime.parse(json['dataDate'] as String),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'base': base,
        'rates': rates,
        'dataDate': dataDate.toUtc().toIso8601String(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  /// Parses just the rates map from a fawazahmed0 document (also used for
  /// historical snapshots).
  static Map<String, double> parseFawazRates(Map<String, dynamic> json) {
    final raw = json['usd'];
    if (raw is! Map) throw const ServerFailure('Malformed rates response.');

    final rates = <String, double>{};
    raw.forEach((key, value) {
      if (value is num && value > 0) {
        rates[(key as String).toUpperCase()] = value.toDouble();
      }
    });
    rates['USD'] = 1;
    return rates;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime.utc(y, m, d);
  }
}
