/// All network endpoints live here so a data source can be swapped in one place.
///
/// Primary + fallback: https://github.com/fawazahmed0/exchange-api
/// (free, no API key, 200+ currencies incl. crypto, dated snapshots for charts).
/// Last resort: open.er-api.com (free, no key, ~160 fiat currencies).
abstract final class ApiConstants {
  /// [date] is either `latest` or `YYYY-MM-DD`.
  static String primary(String date) =>
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$date/v1/currencies/usd.json';

  static String fallback(String date) =>
      'https://$date.currency-api.pages.dev/v1/currencies/usd.json';

  static const String erApiLatest = 'https://open.er-api.com/v6/latest/USD';

  static const String flagCdn = 'https://flagcdn.com/w160';
}
