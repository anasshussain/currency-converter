import '../entities/conversion_record.dart';

abstract interface class HistoryRepository {
  List<ConversionRecord> getAll();

  Future<void> saveAll(List<ConversionRecord> records);
}
