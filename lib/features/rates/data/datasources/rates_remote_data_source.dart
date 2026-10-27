import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/exchange_rates_model.dart';

abstract interface class RatesRemoteDataSource {
  Future<ExchangeRatesModel> fetchLatest();

  /// [date] formatted as `YYYY-MM-DD`.
  Future<Map<String, double>> fetchHistorical(String date);
}

/// Tries several free providers in order so a single outage never breaks the app.
class RatesRemoteDataSourceImpl implements RatesRemoteDataSource {
  RatesRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<ExchangeRatesModel> fetchLatest() {
    final fetchedAt = DateTime.now();
    return _firstSuccess<ExchangeRatesModel>([
      () async => ExchangeRatesModel.fromFawaz(
            await _client.getJson(ApiConstants.primary('latest')),
            fetchedAt: fetchedAt,
          ),
      () async => ExchangeRatesModel.fromFawaz(
            await _client.getJson(ApiConstants.fallback('latest')),
            fetchedAt: fetchedAt,
          ),
      () async => ExchangeRatesModel.fromErApi(
            await _client.getJson(ApiConstants.erApiLatest),
            fetchedAt: fetchedAt,
          ),
    ]);
  }

  @override
  Future<Map<String, double>> fetchHistorical(String date) {
    return _firstSuccess<Map<String, double>>([
      () async => ExchangeRatesModel.parseFawazRates(
            await _client.getJson(ApiConstants.primary(date)),
          ),
      () async => ExchangeRatesModel.parseFawazRates(
            await _client.getJson(ApiConstants.fallback(date)),
          ),
    ]);
  }

  Future<T> _firstSuccess<T>(List<Future<T> Function()> attempts) async {
    Failure? lastFailure;
    for (final attempt in attempts) {
      try {
        return await attempt();
      } on Failure catch (failure) {
        lastFailure = failure;
      }
    }
    throw lastFailure ?? const ServerFailure();
  }
}
