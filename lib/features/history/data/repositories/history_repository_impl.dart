import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/conversion_record.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._storage);

  static const _key = 'conversion_history_v1';

  final LocalStorage _storage;

  @override
  List<ConversionRecord> getAll() {
    final raw = _storage.read(_key);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list)
          ConversionRecord.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveAll(List<ConversionRecord> records) {
    return _storage.write(
      _key,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }
}
