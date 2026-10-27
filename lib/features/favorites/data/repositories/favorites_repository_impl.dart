import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._storage);

  static const _key = 'favorite_currencies_v1';

  final LocalStorage _storage;

  @override
  List<String> getAll() {
    final raw = _storage.read(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveAll(List<String> codes) {
    return _storage.write(_key, jsonEncode(codes));
  }
}
