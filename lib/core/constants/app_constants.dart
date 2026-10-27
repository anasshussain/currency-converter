abstract final class AppConstants {
  static const String defaultFrom = 'USD';
  static const String defaultTo = 'PKR';
  static const String defaultAmount = '100';

  /// Cached rates younger than this are served without hitting the network.
  static const Duration ratesCacheTtl = Duration(minutes: 30);

  /// Rates are silently refreshed while the app is open.
  static const Duration autoRefresh = Duration(minutes: 5);

  static const Duration requestTimeout = Duration(seconds: 15);

  static const int historyLimit = 100;
}
