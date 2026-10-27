import 'package:equatable/equatable.dart';

enum CurrencyType { fiat, crypto }

class Currency extends Equatable {
  const Currency({
    required this.code,
    required this.name,
    this.countryCode,
    this.type = CurrencyType.fiat,
    this.isMajor = false,
  });

  /// ISO 4217 code (USD, PKR, ...) or crypto ticker (BTC, ETH, ...).
  final String code;
  final String name;

  /// ISO 3166-1 alpha-2 code used to display the country flag.
  final String? countryCode;
  final CurrencyType type;
  final bool isMajor;

  bool get isCrypto => type == CurrencyType.crypto;

  @override
  List<Object?> get props => [code, name, countryCode, type, isMajor];
}
