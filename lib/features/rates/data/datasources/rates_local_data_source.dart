import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../models/exchange_rates_model.dart';

abstract interface class RatesLocalDataSource {
  ExchangeRatesModel? readRates();

  Future<void> saveRates(ExchangeRatesModel rates);
}

class RatesLocalDataSourceImpl implements RatesLocalDataSource {
  RatesLocalDataSourceImpl(this._storage);

  static const _key = 'cached_rates_v1';

  final LocalStorage _storage;

  @override
  ExchangeRatesModel? readRates() {
    final raw = _storage.read(_key);
    if (raw == null) return null;
    try {
      return ExchangeRatesModel.fromCacheJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      // Corrupted cache is simply ignored; fresh rates will replace it.
      return null;
    }
  }

  @override
  Future<void> saveRates(ExchangeRatesModel rates) {
    return _storage.write(_key, jsonEncode(rates.toCacheJson()));
  }
}
