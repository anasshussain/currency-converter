import '../entities/exchange_rates.dart';
import '../repositories/rates_repository.dart';

class GetLatestRates {
  const GetLatestRates(this._repository);

  final RatesRepository _repository;

  Future<ExchangeRates> call({bool forceRefresh = false}) {
    return _repository.getLatestRates(forceRefresh: forceRefresh);
  }
}
