import '../entities/currency.dart';

abstract interface class CurrencyRepository {
  /// Every currency known to the app (metadata only, no rates).
  List<Currency> getAll();

  /// Returns metadata for [code], or a generic placeholder if unknown.
  Currency getByCode(String code);
}
