import '../entities/rate_alert.dart';

abstract interface class AlertsRepository {
  List<RateAlert> getAll();

  Future<void> saveAll(List<RateAlert> alerts);
}
