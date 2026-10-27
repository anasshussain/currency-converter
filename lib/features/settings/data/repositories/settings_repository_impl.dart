import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/storage/local_storage.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  static const _themeKey = 'theme_mode_v1';
  static const _pairKey = 'last_pair_v1';

  final LocalStorage _storage;

  @override
  ThemeMode getThemeMode() {
    final name = _storage.read(_themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    return _storage.write(_themeKey, mode.name);
  }

  @override
  ({String from, String to})? getLastPair() {
    final raw = _storage.read(_pairKey);
    final parts = raw?.split('>');
    if (parts == null || parts.length != 2) return null;
    return (from: parts[0], to: parts[1]);
  }

  @override
  Future<void> setLastPair({required String from, required String to}) {
    return _storage.write(_pairKey, '$from>$to');
  }
}
