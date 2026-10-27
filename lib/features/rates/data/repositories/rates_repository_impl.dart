import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/exchange_rates.dart';
import '../../domain/repositories/rates_repository.dart';
import '../datasources/rates_local_data_source.dart';
import '../datasources/rates_remote_data_source.dart';

class RatesRepositoryImpl implements RatesRepository {
  RatesRepositoryImpl({
    required RatesRemoteDataSource remote,
    required RatesLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final RatesRemoteDataSource _remote;
  final RatesLocalDataSource _local;

  /// Historical snapshots never change, so they are cached for the session.
  final Map<String, Map<String, double>> _historyCache = {};

  @override
  Future<ExchangeRates> getLatestRates({bool forceRefresh = false}) async {
    final cached = _local.readRates();

    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) < AppConstants.ratesCacheTtl) {
      return cached;
    }

    try {
      final fresh = await _remote.fetchLatest();
      await _local.saveRates(fresh);
      return fresh;
    } on Failure {
      if (cached != null) return cached.copyWith(isStale: true);
      rethrow;
    }
  }

  @override
  Future<Map<String, double>?> getHistoricalRates(DateTime date) async {
    final key = Formatters.apiDate(date);
    final hit = _historyCache[key];
    if (hit != null) return hit;

    final rates = await _remote.fetchHistorical(key);
    _historyCache[key] = rates;
    return rates;
  }
}
