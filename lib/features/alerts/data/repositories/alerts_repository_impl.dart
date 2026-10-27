import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/rate_alert.dart';
import '../../domain/repositories/alerts_repository.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  AlertsRepositoryImpl(this._storage);

  static const _key = 'rate_alerts_v1';

  final LocalStorage _storage;

  @override
  List<RateAlert> getAll() {
    final raw = _storage.read(_key);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list) RateAlert.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveAll(List<RateAlert> alerts) {
    return _storage.write(
      _key,
      jsonEncode(alerts.map((a) => a.toJson()).toList()),
    );
  }
}
