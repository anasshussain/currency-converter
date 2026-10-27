import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/alerts/data/repositories/alerts_repository_impl.dart';
import '../../features/alerts/domain/repositories/alerts_repository.dart';
import '../../features/currencies/data/repositories/currency_repository_impl.dart';
import '../../features/currencies/domain/repositories/currency_repository.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/rates/data/datasources/rates_local_data_source.dart';
import '../../features/rates/data/datasources/rates_remote_data_source.dart';
import '../../features/rates/data/repositories/rates_repository_impl.dart';
import '../../features/rates/domain/repositories/rates_repository.dart';
import '../../features/rates/domain/usecases/convert_currency.dart';
import '../../features/rates/domain/usecases/get_daily_change.dart';
import '../../features/rates/domain/usecases/get_latest_rates.dart';
import '../../features/rates/domain/usecases/get_rate_history.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../network/api_client.dart';
import '../storage/local_storage.dart';

/// Composition root: every dependency of the app is wired here, once.
/// Overridden in `main()` with the real [SharedPreferences] instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

// ── Core ────────────────────────────────────────────────────────────────────
final localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorage(ref.watch(sharedPreferencesProvider)),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(httpClientProvider)),
);

// ── Rates ───────────────────────────────────────────────────────────────────
final ratesRemoteDataSourceProvider = Provider<RatesRemoteDataSource>(
  (ref) => RatesRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final ratesLocalDataSourceProvider = Provider<RatesLocalDataSource>(
  (ref) => RatesLocalDataSourceImpl(ref.watch(localStorageProvider)),
);

final ratesRepositoryProvider = Provider<RatesRepository>(
  (ref) => RatesRepositoryImpl(
    remote: ref.watch(ratesRemoteDataSourceProvider),
    local: ref.watch(ratesLocalDataSourceProvider),
  ),
);

final getLatestRatesProvider = Provider<GetLatestRates>(
  (ref) => GetLatestRates(ref.watch(ratesRepositoryProvider)),
);

final getDailyChangeProvider = Provider<GetDailyChange>(
  (ref) => GetDailyChange(ref.watch(ratesRepositoryProvider)),
);

final getRateHistoryProvider = Provider<GetRateHistory>(
  (ref) => GetRateHistory(ref.watch(ratesRepositoryProvider)),
);

final convertCurrencyProvider = Provider<ConvertCurrency>(
  (ref) => const ConvertCurrency(),
);

// ── Other features ──────────────────────────────────────────────────────────
final currencyRepositoryProvider = Provider<CurrencyRepository>(
  (ref) => const CurrencyRepositoryImpl(),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(ref.watch(localStorageProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(ref.watch(localStorageProvider)),
);

final alertsRepositoryProvider = Provider<AlertsRepository>(
  (ref) => AlertsRepositoryImpl(ref.watch(localStorageProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(localStorageProvider)),
);
