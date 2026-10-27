import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_catalog.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  const CurrencyRepositoryImpl();

  @override
  List<Currency> getAll() => CurrencyCatalog.all;

  @override
  Currency getByCode(String code) => CurrencyCatalog.byCode(code);
}
